require 'opengraph'

class PagesController < ApplicationController
  # GET /pages
  # GET /pages.json
  def index
    @page = Page.new
    @pages = Page.all(:order => "id DESC")

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @pages }
    end
  end

  # GET /pages/1
  # GET /pages/1.json
  def show
    @page = Page.find_by_id(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @page }
    end
  end

  def scrape(page)
    if (obj = OpenGraph.fetch(@page.url, false, true))
      logger.debug('Fetch ' + @page.url + ': ' + obj.to_yaml)
      @page.title = obj.title if obj.title
      @page.description = obj.description if obj.description
      @page.thumbnail = obj.image if obj.image
    end
  end

  # GET /url
  def show_url
    query =  Rack::Utils.parse_nested_query(request.query_string)
    query.delete('format')
    @url = params[:protocol] + "://" + params[:url] + (query.empty? ? '' : '?') + query.to_query
    logger.debug("url: " + @url)
    @page = Page.new(:url => @url) unless @page = Page.find_by_url(@url) || @page = Page.find_by_url(@url + '/')
    if (@page.new_record? || @page.updated_at < 1.hour.ago)
      scrape @page
      @page.touch
      @page.save
    end

    respond_to do |format|
      format.html { render :action => 'show' }
      format.json { render json: @page }
    end
  end

  # GET /pages/new
  # GET /pages/new.json
  def new
    @page = Page.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @page }
    end
  end

  # GET /pages/1/edit
  def edit
    @page = Page.find(params[:id])
  end

  # POST /pages
  # POST /pages.json
  def create
    @page = Page.new(params[:page])
    scrape @page

    respond_to do |format|
      if @page.save
        format.html { redirect_to @page, notice: 'Page was successfully created.' }
        format.json { render json: @page, status: :created, location: @page }
      else
        format.html { render action: "new" }
        format.json { render json: @page.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /pages/1
  # PUT /pages/1.json
  def update
    @page = Page.find(params[:id])

    respond_to do |format|
      if @page.update_attributes(params[:page])
        format.html { redirect_to @page, notice: 'Page was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @page.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pages/1
  # DELETE /pages/1.json
  def destroy
    @page = Page.find(params[:id])
    @page.destroy

    respond_to do |format|
      format.html { redirect_to pages_url }
      format.json { head :no_content }
    end
  end
end
