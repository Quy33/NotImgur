//
//  ImgurNetworkManager.swift
//  NotImgur
//
//  Created by Mcrew-Tech on 02/11/2021.
//

import UIKit


struct ImgurNetworkManager {
    private let baseURL = "https://api.imgur.com/3"
    
    private let clientID = "Client-ID 11dd115895de7c5"
    
    private let secret = "de0848f79adcf51b1469d66a475bc590b37c8085"

//MARK: Getting Gallery Information
    func requestGallery(section: GalleryKey.Section = .hot, sort: GalleryKey.Sort = .viral, window: GalleryKey.Window = .day, page: Int = 0) async throws -> ImageModel
    {
        //Filling the URL for when calling the API
        let gallery = GalleryKey(sectionID: section, sortID: sort, windowID: window)
        //Making the URL
        guard let urlComponents = URLComponents(string: "\(baseURL)/gallery/\(gallery.section)/\(gallery.sort)/\(gallery.window)/\(page)")
        else {
            throw ImageDownloadError.invalidData
        }
        var request = URLRequest(url: urlComponents.url!)
        request.setValue(clientID, forHTTPHeaderField: "Authorization")
        
        let (data,response) = try await URLSession.shared.data(for: request)
        //Checking For error from the response
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw ImageDownloadError.invalidData
        }
        //Getting data
        guard let model = parseGallery(data) else {
            throw ImageDownloadError.invalidData
        }
        return model
    }

//MARK: Download all Images Thumbnail From Gallery
    func downloadBatches(links: [URL]) async throws  {
//        //Downloading
//        for link in links {
//            let request = URLRequest(url: link)
//            let (data,response) = try await URLSession.shared.data(for: request)
////            print("\((response as? HTTPURLResponse)?.statusCode) : \(link)")
//            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
//                throw ImageDownloadError.errorDownloading
//            }
//
//            guard let image = UIImage(data: data) else {
//                throw ImageDownloadError.errorDownloading
//            }
//            images.append(image)
//        }
//        return images
    }
    
    func singleDownload(with link: URL) async throws -> UIImage {
        let request = URLRequest(url: link)
        let (data,response) = try await URLSession.shared.data(for: request)
//            print("\((response as? HTTPURLResponse)?.statusCode) : \(url)")
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw ImageDownloadError.badImage
        }

        guard let image = UIImage(data: data) else {
            throw ImageDownloadError.badImage
        }
        return image
    }

//MARK: Updating Gallery Item model to move to detail screen and then to be use for API Call
    func configProperty(model: ImageModel, with items: inout [ImgurGalleryItem]) {
        for i in 0..<model.data.count {
            items[i].id = model.data[i].id
            items[i].isAlbum = model.data[i].is_album
        }
    }
     
//MARK: Misc Function
    func getLinks(from model: ImageModel) throws -> [URL] {
        let links = try getImgLink(with: model)
        var urls = [URL]()
        //Check links
        for link in links {
            guard let url = URL(string: link) else {
                throw ImageDownloadError.badImage
            }
            urls.append(url)
        }
        return urls
    }
    private func getImgLink(with model: ImageModel) throws ->[String]{
        var links = [String]()
        for item in model.data {
            links.append(try concatStr(with: sortingType(with: item)))
        }
        return links
    }
    private func concatStr(with string: String) throws -> String {
        var result = string
        guard let i = result.lastIndex(of: ".") else {
            throw ImageDownloadError.badURL
        }
        result.insert("m", at: i)
        return result
    }
    
    private func parseGallery(_ data: Data)-> ImageModel? {
        do {
            let decodedData = try JSONDecoder().decode(ImageModel.self, from: data)
            return decodedData
        } catch {
            print(error)
            return nil
        }
    }
    func sortingType(with obj: SingleImage) throws -> String {
        var link = ""
        //Can safely force unwrap images
        if obj.is_album {
            //Check if it isnt an image
            let firstImg = obj.images![0]
            if firstImg.animated {
                //Checking for video type
                guard let type = ImageType.init(rawValue: firstImg.type) else {
                    throw ImageDownloadError.badURL
                }
                switch type {
                case .mp4:
                    link = firstImg.mp4!
                case .gif:
                    link = firstImg.gifv!
                }
            } else {
                link = firstImg.link
            }
        } else {
            if obj.animated! {
                guard let type = ImageType.init(rawValue: obj.type!) else {
                    throw ImageDownloadError.badURL
                }
                switch type {
                case .mp4:
                    link = obj.mp4!
                case .gif:
                    link = obj.gifv!
                }
            } else {
                link = obj.link
            }
        }
        return link
    }
    
//MARK: Key for gallery when calling API
    struct GalleryKey {
        let sectionID: Section
        let sortID: Sort
        let windowID: Window

        //Get String values to Make URL
        var section: String {
            sectionID.rawValue
        }
        var sort: String {
            sortID.rawValue
        }
        var window: String {
            windowID.rawValue
        }
        // Enum to match key for the function
        enum Section: String {
            case hot = "hot"
            case top = "top"
            case user = "user"
        }
        enum Sort: String {
            case viral = "viral"
            case top = "top"
            case time = "time"
            case rising = "rising"
        }
        enum Window: String {
            case day = "day"
            case week = "week"
            case month = "month"
            case all = "all"
        }
    }
    //MARK: Error Enums
    enum ImageDownloadError: Error {
        case invalidData
        case badImage
        case errorDownloading
        case badURL
    }
    //MARK: Gallery image Type enum
    enum ImageType: String {
        case mp4 = "video/mp4"
        case gif = "image/gif"
//        case jpeg = "image/jpeg"
//        case png = "image/png"
    }
}
