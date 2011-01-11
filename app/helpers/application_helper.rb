module ApplicationHelper

  NICE_FORMATS = {
    :date => '%b %e, %Y',
    :time => '%I:%M %p',
    :datetime => '%b %e, %Y %I:%M %p',
    :datetimesec => '%b %e, %Y %I:%M:%S %p' }

  def nice(format, time)
    strf = NICE_FORMATS.fetch(format) do
      raise ArgumentError, "unknown format: #{format.inspect}"
    end
    time.to_time.strftime(strf)
  end

  def discount(md)
    return unless md
    raw(RDiscount.new(md).to_html)
  end

  def title(value = nil)
    value ? @title = value : haml_tag(:title, @title)
  end

  def google_analytics_fragment
    raw <<-SCRIPT
<script type="text/javascript">
var _gaq = _gaq || [];
_gaq.push(['_setAccount', 'UA-8617929-2']);
_gaq.push(['_trackPageview']);

(function() {
  var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
  ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
  (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(ga);
})();
</script>
SCRIPT
  end

end
