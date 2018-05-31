module Rw
  class JalaliToGregorian
    include Interactor

    JalaliSplitted = Struct.new(:year, :month, :day)

    def call
      if context.date
        splitted = split_jalali_date(context.date)
      else
        splitted = split_date
      end
      year = splitted.year
      month = splitted.month
      day = splitted.day
      context.result = Parsi::Date.parse("#{year}/#{month}/#{day}").to_gregorian
    rescue
      context.result = nil
    end

    private

    def split_date
      splitted = JalaliSplitted.new
      splitted.year = context.year
      splitted.month = context.month
      splitted.day = context.day
      splitted
    end

    def split_jalali_date(jalali_date)
      jalali_splitted = JalaliSplitted.new
      jalali_splitted.year = jalali_date[0..3].to_i
      jalali_splitted.month = jalali_date[5..6].to_i
      jalali_splitted.day = jalali_date[8..9].to_i
      jalali_splitted
    end
  end
end