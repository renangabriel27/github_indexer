// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"

// Import controllers manually
import FlashController from "controllers/flash_controller"
import ModalController from "controllers/modal_controller"
import SearchController from "controllers/search_controller"
import SearchDebounceController from "controllers/search_debounce_controller"
import ProfileProgressController from "controllers/profile_progress_controller"

// Register controllers
application.register("flash", FlashController)
application.register("modal", ModalController)
application.register("search", SearchController)
application.register("search-debounce", SearchDebounceController)
application.register("profile-progress", ProfileProgressController)
