description 'db stack'

include_template(
    'db/dyn_accounts.rb',
    'db/dyn_statements.rb',
    'db/s3.rb'
)
