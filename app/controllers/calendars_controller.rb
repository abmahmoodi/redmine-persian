# Redmine - project management software
# Copyright (C) 2006-2016  Jean-Philippe Lang
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

class CalendarsController < ApplicationController
  menu_item :calendar
  before_action :find_optional_project

  rescue_from Query::StatementInvalid, :with => :query_statement_invalid

  helper :issues
  helper :projects
  helper :queries
  include QueriesHelper
  helper :sort
  include SortHelper

  def show
    if params[:year] and params[:year].to_i > 1300
      @year = params[:year].to_i
      if params[:month] and params[:month].to_i > 0 and params[:month].to_i < 13
        @month = params[:month].to_i
      end
    end

    @year ||= User.current.today.to_parsi.year
    @month ||= User.current.today.to_parsi.month

    @calendar = Redmine::Helpers::Calendar.new(Parsi::Date.parse("#{@year}/#{@month}/01"), current_language, :month)
    retrieve_query
    @query.group_by = nil
    if @query.valid?
      events = []

      startdt_gr = Parsi::Date.parse("#{@calendar.startdt.year}/#{@calendar.startdt.month}/#{@calendar.startdt.day}").to_gregorian
      enddt_gr = Parsi::Date.parse("#{@calendar.enddt.year}/#{@calendar.enddt.month}/#{@calendar.enddt.day}").to_gregorian

      events += @query.issues(:include => [:tracker, :assigned_to, :priority],
                              :conditions => ["((start_date BETWEEN ? AND ?) OR (due_date BETWEEN ? AND ?))", startdt_gr, enddt_gr, startdt_gr, enddt_gr]
                              )
      events += @query.versions(:conditions => ["effective_date BETWEEN ? AND ?", startdt_gr, enddt_gr])

      @calendar.events = events
    end

    render :action => 'show', :layout => false if request.xhr?
  end
end
