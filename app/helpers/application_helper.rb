module ApplicationHelper

  NICE_FORMATS = {
    :date => '%b %e, %Y',
    :time => '%I:%M %p',
    :datetime => '%b %e, %Y %I:%M %p' }

  def nice(format, time)
    strf = NICE_FORMATS.fetch(format) do
      raise ArgumentError, "unknown format: #{format.inspect}"
    end
    time.to_time.strftime(strf)
  end

end
