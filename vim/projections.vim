let g:rails_projections = {
  \ "app/models/concerns/*.rb": {
  \   "command": "concern",
  \   "template":
  \     "module %S\n  include ActiveSupport::Concern\n\n  included do\n  end\nend",
  \   "keywords": "included"
  \ },
  \ "app/events/*.rb": {
  \   "command": "event",
  \   "alternate": "spec/events/%s_spec.rb",
  \ },
  \ "app/injectors/*_injector.rb": {
  \   "command": "injector",
  \   "alternate": "spec/injectors/%s_injector_spec.rb",
  \ },
  \ "app/repositories/*_repository.rb": {
  \   "command": "repository",
  \   "alternate": "spec/repositories/%s_repository_spec.rb",
  \   "affinity": "model"
  \ },
  \ "app/validators/*_validator.rb": {
  \   "command": "validator",
  \   "alternate": "spec/validators/%s_validator_spec.rb",
  \   "affinity": "model"
  \ },
  \ "app/presenters/*_presenter.rb": {
  \   "command": "presenter",
  \   "alternate": "spec/presenters/%s_presenter_spec.rb",
  \   "affinity": "model"
  \ },
  \ "app/decorators/*_decorator.rb": {
  \   "command": "decorator",
  \   "alternate": "spec/decorators/%s_decorator_spec.rb",
  \   "affinity": "model"
  \ },
  \ "spec/features/*_spec.rb": {
  \   "command": "feature",
  \ },
  \ "spec/support/*.rb": {
  \   "command": "support",
  \ },
  \ "app/workers/*.rb": {
  \   "command": "worker",
  \   "template": "class %S\n  include Sidekiq::Worker\n\n  def perform\n  end\nend",
  \ },
  \ "spec/shared/*.rb": {
  \   "command": "shared",
  \ },
  \ "spec/support/shared_context/*.rb": {
  \   "command": "shcontext",
  \ },
  \ "spec/support/shared_examples/*.rb": {
  \   "command": "shexamples",
  \ },
  \ "spec/factories/*.rb": {
  \   "command": "factory",
  \   "affinity": "collection"
  \ },
  \ "spec/support/factories/*_factory.rb": {
  \   "command": "factory",
  \   "affinity": "collection"
  \ },
  \ "spec/requests/*_spec.rb": {
  \   "command": "request"
  \ },
  \ "app/services/*.rb": {
  \   "command":   "service",
  \   "affinity":  "collection",
  \   "test":      "spec/services/%i_spec.rb",
  \   "template":  "class %S\nend"
  \ },
  \ "app/finders/*.rb": {
  \   "command":   "finder",
  \   "affinity":  "collection",
  \   "test":      "spec/finders/%i_spec.rb",
  \   "template":  "class %S\nend"
  \ },
  \ "app/forms/*_form.rb": {
  \   "command": "form",
  \   "test":    "spec/forms/%i_spec.rb",
  \   "template": "class %S\nend"
  \ },
  \ "app/form_mixins/*_form_mixin.rb": {
  \   "command": "fmixin",
  \   "template": "class %SFormMixin\nend"
  \ },
  \ "app/views/shared/*": { "command": "sview" },
  \ "app-ember/tests/*.js": { "command": "jtest" },
  \ "app-ember/app/templates/*.hbs": { "command": "jtemplate" },
  \ "app-ember/app/templates/components/*.hbs": {
  \   "command": "jctemplate",
  \   "alternate": "app-ember/app/components/{}.js"
  \ },
  \ "app-ember/app/components/*.js": {
  \   "command": "jcomponent",
  \   "alternate": "app-ember/app/templates/components/{}.hbs"
  \ },
  \ "app-ember/app/routes/*.js": { "command": "jroute" },
  \ "app-ember/app/controllers/*.js": { "command": "jcontroller" },
  \ "app-ember/app/helpers/*.js": { "command": "jhelper" },
  \ "app-ember/app/services/*.js": { "command": "jservice" },
  \ "app-ember/app/mixins/*.js": { "command": "jmixin" },
  \ "app-ember/app/initializers/*.js": { "command": "jinitializer" },
  \ "app-ember/app/adapters/*.js": { "command": "jadapter" },
  \ "app-ember/app/serializers/*.js": { "command": "jserializer" },
  \ "app-ember/app/models/*.js": { "command": "jmodel" },
  \ "app-ember/app/templates/shared/*.hbs": { "command": "jpartial" }
  \}

" [vim-rails] gem projections - typing `:Efactory users` will open the users factory, etc.
let g:rails_gem_projections = {
    \   "factory_girl": {
    \     "test/factories/*.rb": {
    \       "command":   "factory",
    \       "affinity":  "collection",
    \       "alternate": "app/models/%i.rb",
    \       "related":   "db/schema.rb#%s",
    \       "test":      "test/models/%i_test.rb",
    \       "template":  "FactoryGirl.define do\n  factory :%i do\n  end\nend",
    \       "keywords":  "factory sequence"
    \     },
    \     "spec/factories/*.rb": {
    \       "command":   "factory",
    \       "affinity":  "collection",
    \       "alternate": "app/models/%i.rb",
    \       "related":   "db/schema.rb#%s",
    \       "test":      "spec/models/%i_test.rb",
    \       "template":  "FactoryGirl.define do\n  factory :%i do\n  end\nend",
    \       "keywords":  "factory sequence"
    \     }
    \   },
    \   "capybara": {
    \     "spec/features/*_spec.rb": {
    \       "command":   "feature",
    \       "template":  "require 'spec_helper'\n\nfeature '%h' do\n\nend"
    \     }
    \   },
    \   "activeadmin": {
    \     "app/admin/*.rb": {
    \       "command":   "admin",
    \       "affinity":  "model",
    \       "test":      "spec/admin/%s_spec.rb",
    \       "related":   "app/models/%s.rb",
    \       "template":  "ActiveAdmin.register %S do\n  config.sort_order = 'created_at_desc'\nend"
    \     }
    \   },
    \   "active_model_serializers": {
    \     "app/serializers/*_serializer.rb": {
    \       "command":   "serializer",
    \       "affinity":  "model",
    \       "test":      "spec/serializers/%s_spec.rb",
    \       "related":   "app/models/%s.rb",
    \       "template":  "class %SSerializer < ActiveModel::Serializer\nend"
    \     }
    \   },
    \   "draper": {
    \     "app/decorators/*_decorator.rb": {
    \       "command":   "decorator",
    \       "affinity":  "model",
    \       "test":      "spec/decorators/%s_spec.rb",
    \       "related":   "app/models/%s.rb",
    \       "template":  "class %SDecorator < Draper::Decorator\n  delegate_all\nend"
    \     }
    \   },
    \   "carrierwave": {
    \     "app/uploaders/*_uploader.rb": {
    \       "command":   "uploader",
    \       "affinity":  "model",
    \       "test":      "spec/uploaders/%s_spec.rb",
    \       "related":   "app/models/%s.rb",
    \       "template":  "class %SUploader < CarrierWave::Uploader::Base\nend"
    \     }
    \   },
    \   "pundit": {
    \     "app/policies/*_policy.rb": {
    \       "command":   "policy",
    \       "affinity":  "model",
    \       "test":      "spec/policies/%s_spec.rb",
    \       "related":   "app/models/%s.rb",
    \       "template":  "class %SPolicy < Struct.new(:user, :%s)\nend"
    \     }
    \   },
    \   "resque": {
    \     "app/jobs/*_job.rb": {
    \       "command":   "job",
    \       "test":      "spec/jobs/%s_spec.rb",
    \       "template":  "class %SJob\n\n  def self.perform\n  end\n\nend"
    \     }
    \   },
    \   "spree": {
    \     "app/models/spree/calculator/*.rb": {
    \       "command": "calculator",
    \       "test":    "spec/models/spree/calculator/%s_spec.rb"
    \     }
    \   },
    \   "cancan": {
    \     "app/models/ability/*_role.rb": {
    \       "command":   "ability",
    \       "related":   "app/models/user.rb"
    \     },
    \     "app/models/ability.rb": {
    \       "command":   "ability",
    \       "related":   "app/models/user.rb"
    \     }
    \   }
    \ }
