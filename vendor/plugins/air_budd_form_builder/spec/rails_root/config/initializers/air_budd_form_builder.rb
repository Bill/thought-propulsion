# borrowed from shoulda test
# This simulates loading the air_budd_form_builder plugin, but without relying on
# vendor/plugins (since this lil' Rails app is inside that very plugin!)

plugin_path = File.join(File.dirname(__FILE__), *%w(.. .. .. ..))
plugin_lib_path = File.join(plugin_path, "lib")
 
$LOAD_PATH.unshift(plugin_lib_path)
load File.join(plugin_path, "init.rb")