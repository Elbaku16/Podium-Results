import UIKit
import Observation

@MainActor
@Observable
final class ProfilePhotoViewModel {
    private let store = ProfilePhotoStore()
    private var key = "guest"

    var image: UIImage?

    func load(for uid: String?) {
        let newKey = uid ?? "guest"
        key = newKey
        Task {
            let loaded = await Task.detached { ProfilePhotoStore().load(for: newKey) }.value
            if key == newKey { image = loaded }
        }
    }

    func setPhoto(_ data: Data) async {
        let current = key
        let saved = await Task.detached { ProfilePhotoStore().save(data, for: current) }.value
        if key == current { image = saved }
    }

    func removePhoto() {
        store.remove(for: key)
        image = nil
    }
}
