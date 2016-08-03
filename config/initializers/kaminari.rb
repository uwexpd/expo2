# If you use will_paginate in your app, you need to configure an initializer for Kaminari to avoid conflicts.
# https://github.com/activeadmin/activeadmin/blob/master/docs/0-installation.md#will_paginate
Kaminari.configure do |config|
  config.page_method_name = :per_page_kaminari
end