import UIKit

struct ProfilePhotoStore {
    private func url(for key: String) -> URL {
        let folder = URL.applicationSupportDirectory.appending(path: "ProfilePhotos", directoryHint: .isDirectory)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder.appending(path: "\(key).jpg")
    }

    func load(for key: String) -> UIImage? {
        UIImage(contentsOfFile: url(for: key).path)
    }

    func save(_ data: Data, for key: String) -> UIImage? {
        guard let image = UIImage(data: data) else { return nil }
        let side: CGFloat = 600
        let scale = min(1, side / max(image.size.width, image.size.height))
        let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let resized = UIGraphicsImageRenderer(size: size).image { _ in image.draw(in: CGRect(origin: .zero, size: size)) }
        guard let jpeg = resized.jpegData(compressionQuality: 0.85) else { return nil }
        try? jpeg.write(to: url(for: key), options: .atomic)
        return resized
    }

    func remove(for key: String) {
        try? FileManager.default.removeItem(at: url(for: key))
    }
}
