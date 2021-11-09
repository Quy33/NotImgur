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
    
    var sizeOfThumbnail: Character {
        return configThumbnail.rawValue
    }
    
    var configThumbnail: ThumbnailSize = .smallThumbnail
    

//MARK: Getting Gallery Information
    func requestGallery(section: GalleryKey.Section = .hot, sort: GalleryKey.Sort = .viral, window: GalleryKey.Window = .day, page: Int = 0) async throws -> GalleryModel
    {
        //Filling the URL for when calling the API
        let gallery = GalleryKey(sectionID: section, sortID: sort, windowID: window)
        //Making the URL
        guard var urlComponents = URLComponents(string: "\(baseURL)/gallery/\(gallery.section)/\(gallery.sort)/\(gallery.window)/\(page)")
        else {
            throw ImageDownloadError.invalidData
        }
        
//        urlComponents.queryItems = [
//            URLQueryItem(name: "mature", value: "false")
//        ]
        
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
    func multipleDownload(with links: [URL]) async throws -> [UIImage] {
        return await withTaskGroup(of: UIImage.self, body: { group in
            for link in links {
                group.addTask {
                    do {
                        let image = try await singleDownload(with: link)
                        return image
                    } catch {
                        return UIImage(named: "placeholder")!
                    }
                }
            }
            var results = [UIImage]()
            for await result in group {
                results.append(result)
            }
            return results
        })
    }

//MARK: Updating Gallery Item model to move to detail screen and then to be use for API Call
    func configProperty(model: GalleryModel, with items: inout [ImgurGalleryItem]) {
        for i in 0..<model.data.count {
            items[i].id = model.data[i].id
            items[i].isAlbum = model.data[i].is_album
            items[i].type = model.data[i].type ?? model.data[i].images![0].type
            items[i].title = model.data[i].title
        }
    }
     
//MARK: Misc Function
    func getLinks(from model: GalleryModel) throws -> [URL] {
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
    private func getImgLink(with model: GalleryModel) throws ->[String]{
        var links = [String]()
        for item in model.data {
            links.append(try concatStr(with: sortingGallery(with: item)))
        }
        return links
    }
    private func concatStr(with string: String) throws -> String {
        var result = string
        guard let i = result.lastIndex(of: ".") else {
            throw ImageDownloadError.badURL
        }
        result.insert(sizeOfThumbnail, at: i)
        return result
    }
    
    private func parseGallery(_ data: Data)-> GalleryModel? {
        do {
            let decodedData = try JSONDecoder().decode(GalleryModel.self, from: data)
            return decodedData
        } catch {
            print(error)
            return nil
        }
    }
    
    private func sortingGallery(with obj: SingleImage) throws -> String {
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
                default:
                    throw ImageDownloadError.badURL
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
                default:
                    throw ImageDownloadError.badURL
                }
            } else {
                link = obj.link
            }
        }

        return link
    }
    
//MARK: Detail Screen Networking
    
    func getDetail(with tuple: (id: String, isAlbum: Bool) ) async throws -> DetailModel{
        
        let detail = tuple.isAlbum ? "album" : "image"
        
        let urlString = "\(baseURL)/\(detail)/\(tuple.id)"
        
        guard let url = URL(string: urlString) else {
            throw ImageDownloadError.badURL
        }
        
        var request = URLRequest(url: url)
        request.setValue(clientID, forHTTPHeaderField: "Authorization")
        
        let (data,response) = try await URLSession.shared.data(for: request)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw ImageDownloadError.invalidData
        }
        
        //print(String(data: data, encoding: .utf8)!)
        let model = try parseDetail(data)
        return model
    }
    
    private func parseDetail(_ data: Data) throws -> DetailModel {
        do {
            let decodedData = try JSONDecoder().decode(DetailModel.self, from: data)
            return decodedData
        } catch {
            throw error
        }
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
        case png = "image/png"
        case jpeg = "image/jpeg"
    }
    enum ThumbnailSize: Character {
        case smallSquare = "s"
        case bigSquare = "b"
        case smallThumbnail = "t"
        case mediumThumbnail = "m"
        case largeThumbnail = "l"
        case hugeThumbnail = "h"
    }
}
