class SearchController < BaseController
  autocomplete :user, :email
end
