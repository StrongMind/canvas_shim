# Canvas includes the root by default - unlike vanilla rails.  This makes shim
# act like Canvas
ActiveRecord::Base.include_root_in_json = true
