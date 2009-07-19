# Install file for dnsbl_check Rails plugin
# http://www.spacebabies.nl/dnsbl_check

require 'fileutils'

# copy the chique 403 template to the public folder
forbidden_template = File.dirname(__FILE__) + '/../../../public/403.html'
FileUtils.cp File.dirname(__FILE__) + '/403.html', forbidden_template unless File.exist?(forbidden_template)

# display installation instructions
puts <<INSTALL

Thank you for installing the dnsbl_check Rails plugin.

USAGE INSTRUCTION

Put this in any controller that needs checking:
before_filter :dnsbl_check

Abuse is often limited to a few controllers in your application, e.g. the one
that receives comments. If you need checking in your entire application, put
the before_filter in your ApplicationController.

Restart your Rails application after you've made the above change(s).
INSTALL
