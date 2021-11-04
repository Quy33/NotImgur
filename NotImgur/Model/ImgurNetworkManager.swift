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
//        for i in 0..<model.data.count {
//            print("\(model.data[i].is_album):\(i)")
//        }
//        print(String(data: data, encoding: .utf8)!)
//        for item in model.data {
//            if item.is_album {
//                print(item.images![0].type)
//            } else {
//                print(item.type!)
//            }
//        }
        return model
    }

//MARK: Download all Images Thumbnail From Gallery
    func downloadImage(_ model: ImageModel) async throws -> [UIImage] {
        guard let links = try? getImgLink(with: model) else {
            print("Here? 1")
            throw ImageDownloadError.badImage
        }
        var urls = [URL]()
        var images = [UIImage]()
        //Check links
        for link in links {
            guard let url = URL(string: link) else {
                print("Check Links failed")
                throw ImageDownloadError.badImage
            }
            urls.append(url)
        }
        //Downloading
        for url in urls {
            let request = URLRequest(url: url)
            //print(url)
            let (data,response) = try await URLSession.shared.data(for: request)
//            print("\((response as? HTTPURLResponse)?.statusCode) : \(url)")
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                print("Here? 2")
                throw ImageDownloadError.badImage
            }

            guard let image = UIImage(data: data) else {
                print("Problem making an image")
                throw ImageDownloadError.badImage
            }
            images.append(image)
        }
        return images
    }

//MARK: Getting the Gallery Item model to move to detail screen and then to be use for API Call
    func getImgurModels(with model: ImageModel)->[ImgurGalleryItem]{
        var stackOfModel = [ImgurGalleryItem]()
        for item in model.data {
            let newModel = ImgurGalleryItem(id: item.id, is_album: item.is_album)
            stackOfModel.append(newModel)
        }
        return stackOfModel
    }
     
//MARK: Misc Function
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
            throw ImageDownloadError.badImage
        }
        result.insert("t", at: i)
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
    func sortingType(with obj: SingleImage) -> String {
        var link = ""
        //Can safely force unwrap images
        if obj.is_album {
            //Check if it isnt an image
            let firstImg = obj.images![0]
            if firstImg.animated {
                //Checking for video type
                guard let type = ImageType.init(rawValue: firstImg.type) else {
                    fatalError("Wrong type")
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
                    fatalError("Wrong type")
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
    }
    //MARK: Gallery image Type enum
    enum ImageType: String {
        case mp4 = "video/mp4"
        case gif = "image/gif"
//        case jpeg = "image/jpeg"
//        case png = "image/png"
    }
}
