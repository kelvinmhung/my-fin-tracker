require 'csv'
#require 'iconv'
require 'highcharts-rails'
require 'active_support'

class ExpensesController < ApplicationController
  before_filter :authenticate_user!

  # GET /expenses
  # GET /expenses.json
  def index
    @expense_by_category_and_month = {}
    @expense_by_category = {}
    expenses_total_by_month = {}
    @expense_month = []
    @expense_total = []
    @expenses = current_user.expenses.all
    if @expenses.present?
      @start_date = @expenses[0].date
    end


    # hack to make sure it is not nil
    @expense_by_category_and_month['Bills & Utilities'] = []
    @expense_by_category_and_month['Food & Dining'] = []
    @expense_by_category_and_month['Auto & Transport'] = []
    @expense_by_category_and_month['Entertainment'] = []
    @expense_by_category_and_month['Health & Fitness'] = []
    @expense_by_category_and_month['Shopping'] = []
    @expense_by_category_and_month['Kids'] = []
    @expense_by_category_and_month['Pet'] = []
    @expense_by_category_and_month['Home'] = []
    @expense_by_category_and_month['Uncatagorized'] = []

    expense_by_month_by_category = {}

    current_user.expenses.select("to_char(expenses.date, 'YYYY-MM') as expense_month, expenses.category as expense_category, SUM(expenses.amount_cents) as total").group("category, to_char(expenses.date, 'YYYY-MM')").order("to_char(expenses.date, 'YYYY-MM'), category").each do | exp |

      # Use for column
      if not expense_by_month_by_category.has_key?(exp.expense_month)
        expense_by_month_by_category[exp.expense_month] = {}
      end
      expense_by_month_by_category[exp.expense_month][exp.expense_category] = exp.total.to_i/100


      # Expense by category and month within category
      #if not @expense_by_category_and_month.has_key?(exp.expense_category)
      #  @expense_by_category_and_month[exp.expense_category] = []
      #end
      #@expense_by_category_and_month[exp.expense_category] << exp.total.to_i/100

      # Use for pie chart
      if not @expense_by_category.has_key?(exp.expense_category)
        @expense_by_category[exp.expense_category] = exp.total.to_i/100
      else
        @expense_by_category[exp.expense_category] += exp.total.to_i/100
      end

      # Total expenses by month
      if expenses_total_by_month[exp.expense_month].present?
        expenses_total_by_month[exp.expense_month] += exp.total.to_i/100
      else
        expenses_total_by_month[exp.expense_month] = exp.total.to_i/100
      end
    end

    # Calculate the columns. Handle missing ones
    expense_by_month_by_category.keys.sort.each do | month |
      @expense_by_category_and_month.keys.each do | category |
        if expense_by_month_by_category[month][category].present?
          @expense_by_category_and_month[category] << expense_by_month_by_category[month][category]
        else
          @expense_by_category_and_month[category] << 0
        end
      end

    end


    #current_user.expenses.select("to_char(expenses.date, 'YYYY-MM') as expense_month, SUM(expenses.amount_cents) as total").group("to_char(expenses.date, 'YYYY-MM')").each do | exp |
    #  expenses_total_by_month[exp.expense_month] = exp.total.to_i/100
    #end

    expenses_total_by_month.sort.map {|k,v|  @expense_total << v}

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @expenses }
    end
  rescue
    puts   "#{$!}"
  end

  # GET /expenses/1
  # GET /expenses/1.json
  def show
    @expense = Expense.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @expense }
    end
  end

  # GET /expenses/new
  # GET /expenses/new.json
  def new
    @expense = Expense.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @expense }
    end
  end

  # GET /expenses/1/edit
  def edit
    @expense = Expense.find(params[:id])
  end

  # POST /expenses
  # POST /expenses.json
  def create
    data = params[:expense]

    @expense = current_user.expenses.build(params[:expense])
    if @expense.save
      flash[:success] = "Expense created!"
      redirect_to root_url
    else
      format.html { render action: "new" }
      format.json { render json: @expense.errors, status: :unprocessable_entity }
    end
    #@expense = Expense.new(params[:expense])
    #
    #respond_to do |format|
    #  if @expense.save
    #    format.html { redirect_to @expense, notice: 'Expense was successfully created.' }
    #    format.json { render json: @expense, status: :created, location: @expense }
    #  else
    #    format.html { render action: "new" }
    #    format.json { render json: @expense.errors, status: :unprocessable_entity }
    #  end
    #end
  end

  # PUT /expenses/1
  # PUT /expenses/1.json
  def update
    @expense = Expense.find(params[:id])

    respond_to do |format|
      if @expense.update_attributes(params[:expense])
        format.html { redirect_to @expense, notice: 'Expense was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @expense.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /expenses/1
  # DELETE /expenses/1.json
  def destroy
    @expense = Expense.find(params[:id])
    @expense.destroy

    respond_to do |format|
      format.html { redirect_to expenses_url }
      format.json { head :no_content }
    end
  end

  def import

  end


  def import_file
    infile = params[:file].read
    n=0
    hdr=nil
    CSV.parse(infile) do |row|
      begin
        n+=1
        if n==1
          hdr = row
        else
          if row[0].blank? or row[1].blank? or row[2].blank? or row[3].blank?
            next
          end
          local_dt = DateTime.strptime(row[0], "%m/%d/%Y")
          row[0] = local_dt.iso8601
          record = Hash[[hdr, row].transpose]
          if not record.nil?
            @expense = current_user.expenses.build(record)
            @expense.save!
          end

        end
      rescue
        puts   "#{$!}"
      end
    end

    respond_to do |format|
      format.html { redirect_to expenses_url,notice: 'File imported.' }
      format.json { head :no_content }
    end
  end
end
