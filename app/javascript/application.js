// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import { Application } from "@hotwired/stimulus"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"

// Start Stimulus
window.Stimulus = Application.start()
window.Stimulus.debug = false

eagerLoadControllersFrom("controllers", window.Stimulus)
