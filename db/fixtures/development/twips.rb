# You must explicitly run with rake db:seed RAILS_ENV=development for this seed to be loaded
require 'lorem'
propeller = User.find_by_nickname 'propeller'

twip = Twip.seed( :title) do |t|
  t.title = 'Hyperlinks'
  t.body = <<END
Here is a <a href='thoughtpropulsion.com'>textual hyperlink</a> right there.
And here's an image:
<a href='thoughtpropulsion.com'><img src='http://images.dev.twipl.com.s3.amazonaws.com/images/1/IMG_0260.jpg'></img></a>
END
  t.public = true
  t.author = propeller
end
twip.save!

twip = Twip.seed( :title) do |t|
  t.title = 'Code'
  t.body = <<END
  Here is some Ruby:<pre><code class="ruby">
  &lt;%= some_erb %&gt;
  class ContactController &lt; ThoughtPropulsionApplicationController
    def index
      @vcard = {
        :fn =&gt; 'Thought Propulsion',
        # FIXME: url helper
        :url =&gt; url_for( '/'),
        :addresses =&gt; [
          { :type =&gt; 'meeting', :street_address =&gt; '622 SE Grand Ave.', :locality =&gt; 'Portland', :region =&gt; 'Oregon', :postal_code =&gt; '97214', :country_name =&gt; 'USA'},
          { :type =&gt; 'postal', :post_office_box =&gt; '19863', :locality =&gt; 'Portland', :region =&gt; 'Oregon', :postal_code =&gt; '97280', :country_name =&gt; 'USA'}
        ],
        :emails =&gt; [
          { :type =&gt; 'inquiries', :address =&gt; 'propeller@thoughtpropulsion.com'}
        ],
        :telephones =&gt; [
          {
          :type =&gt; 'work',
          :value =&gt; '503.720.2991'
          }]
      }
    end
  end
  </code></pre>
  Here is some HTML:<br />
  <pre><code class="html">&lt;!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
   "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"&gt;
  &lt;!-- comment --&gt;
  &lt;ul class="vinyl"&gt;<br /> &lt;li&gt;&lt;img src="/assets/2007/12/4/R-150-18062-1192002432.jpg" width="55" alt="Altern8 - Evapor8" /&gt;<br /> 			&lt;span class="track"&gt;&lt;a href="http://www.discogs.com/release/18062"&gt;Evapor8&lt;/a&gt;&lt;/span&gt; <br /> 			&lt;span class="artist"&gt;Altern8&lt;/span&gt;<br /> 			&lt;span class="label"&gt;Network 1992&lt;/span&gt;&lt;/li&gt;<br /> &lt;li&gt;&lt;img src="/assets/2007/12/4/tmb03978.jpg" width="55" alt="Teebone - Down Wid Da Funk (The Sequel)" /&gt;<br /> 			&lt;span class="track"&gt;&lt;a href="http://www.discogs.com/release/171726"&gt;Down Wid Da Funk (The Sequel)&lt;/a&gt;&lt;/span&gt; <br /> 			&lt;span class="artist"&gt;Teebone&lt;/span&gt;<br /> 			&lt;span class="label"&gt;Riddim Track&lt;/span&gt;&lt;/li&gt;<br /> &lt;li&gt;&lt;img src="/assets/2006/12/11/cee-lo.jpg" width="55" alt="Cee-Lo - I'll Be Around" /&gt;<br /> 			&lt;span class="track"&gt;&lt;a href="http://www.discogs.com/release/218091"&gt;I'll Be Around&lt;/a&gt;&lt;/span&gt; <br /> 			&lt;span class="artist"&gt;Cee-Lo w/ Timbaland&lt;/span&gt;<br /> 			&lt;span class="label"&gt;Arista 2003&lt;/span&gt;&lt;/li&gt;<br />&lt;/ul&gt;</code></pre>
  That is all.
END
  t.public = true
  t.author = propeller
end
twip.save!

(0..1).each do |n|
  twip = Twip.seed( :title) do |t|
    # need to make something differ in each record so it will be saved (by seed) so make 
    # title progressively longer
    t.title = Lorem::Base.new('chars', 5 + n).output
    t.body = Lorem::Base.new('paragraphs', 2).output
    t.public = true
    t.author = propeller
  end
  twip.save!
end