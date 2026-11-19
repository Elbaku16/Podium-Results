import UIKit
import Observation

@MainActor
@Observable
final class ProfilePhotoViewModel {
    private let store = ProfilePhotoStore()
    private var key = "guest"

    var image: UIImage?

    func load(for uid: String?) {
        key = uid ?? "guest"
        image = store.load(for: key)
    }

    func setPhoto(_ data: Data) {
        image = store.save(data, for: key)
    }

    func removePhoto() {
        store.remove(for: key)
        image = nil
    }
}
