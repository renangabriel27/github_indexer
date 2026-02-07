// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"

// Import controllers manually
import FlashController from "controllers/flash_controller"
import ModalController from "controllers/modal_controller"
import SearchController from "controllers/search_controller"
import SearchDebounceController from "controllers/search_debounce_controller"

// Register controllers
application.register("flash", FlashController)
application.register("modal", ModalController)
application.register("search", SearchController)
application.register("search-debounce", SearchDebounceController)
