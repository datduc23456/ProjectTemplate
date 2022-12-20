//
//  CoreTargetType.swift
//  ProjectDemo
//
//  Created by Nguyễn Đạt on 08/11/2022.
//

import Foundation
import Moya

enum CoreTargetType: TargetType {
    case movieTopRated(Int)
    case nowPlaying
    case popular(Int)
    case detail(Int)
    case moviegenreid(genreId: Int, page: Int)
    case TVshowgenreid(genreId: Int, page: Int)
    case moviepeopleid(peopleId: Int, page: Int)
    case genreList
    case searchMovie(query: String, page: Int)
    case TVshowPopular(page: Int)
    case TVshowTopRate(page: Int)
    case TVshowLastest(page: Int)
    case TVshowDetail(Int)
    case searchTVshow(query: String, page: Int)
    case personPopular(page: Int)
    case personDetail(personId: Int)
    case searchPerson(query: String, page: Int)
    case upload([String: Any])
    case download(url: String, fileName: String?)
    case getSimularMovie(movieId: Int, page: Int)
    case getSimularTv(tvId: Int, page: Int)
    case getMovieReviews(movieId: Int)
    case getMovieImages(movieId: Int)
    case getTvShowImages(movieId: Int)
    case trendingMovie(page: Int)
    case trendingTvShow(page: Int)
    case newMovie(page: Int)
    var baseURL: URL { return URL(string: "https://api.themoviedb.org/3/")! }
    
    var path: String {
        switch self {
        case .movieTopRated:
            return "movie/top_rated"
        case .nowPlaying:
            return "movie/now_playing"
        case .popular:
            return "movie/popular"
        case .detail(let id):
            return "movie/\(id)"
        case .moviegenreid:
            return "discover/movie"
        case .moviepeopleid:
            return "discover/movie"
        case .TVshowgenreid:
            return "discover/tv"
        case .searchMovie:
            return "search/movie"
        case .TVshowPopular:
            return "tv/popular"
        case .TVshowTopRate:
            return "tv/top_rated"
        case .TVshowLastest:
            return "tv/airing_today"
        case .TVshowDetail(let id):
            return "tv/\(id)"
        case .searchTVshow:
            return "search/tv"
        case .personPopular:
            return "person/popular"
        case .personDetail(let personId):
            return "person/\(personId)"
        case .searchPerson:
            return "search/person"
        case .genreList:
            return "genre/movie/list"
        case .getSimularMovie(let movieId, _):
            return "/movie/\(movieId)/similar"
        case .getSimularTv(let tvId, _):
            return "/tv/\(tvId)/similar"
        case .getMovieReviews(let movieId):
            return "/movie/\(movieId)/reviews"
        case .getMovieImages(let movieId):
            return "/movie/\(movieId)/images"
        case .getTvShowImages(let tvId):
            return "/tv/\(tvId)/images"
        case .trendingMovie:
            return "/trending/movie/day"
        case .trendingTvShow:
            return "/trending/tv/day"
        case .newMovie:
            return "/movie/upcoming"
        default:
            return ""
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .download:
            return .get
        case .upload:
            return .put
        default:
            return .get
        }
    }
    
    var params: [String : Any] {
        var defaultParams: [String: Any] = ["api_key": "63cbd7bb8ca53a31817a418b2cfb7e6a", "language": "en-US"]
        switch self {
        case .popular(let page):
            defaultParams.updateValue(page, forKey: "page")
        case .movieTopRated(let page):
            defaultParams.updateValue(page, forKey: "page")
        case .detail:
            defaultParams.updateValue("videos,credits,recommendations,reviews", forKey: "append_to_response")
        case .moviegenreid(let genreId, let page):
            defaultParams.updateValue(genreId, forKey: "with_genres")
            defaultParams.updateValue(page, forKey: "page")
        case .moviepeopleid(let peopleId, let page):
            defaultParams.updateValue(peopleId, forKey: "with_cast")
            defaultParams.updateValue(page, forKey: "page")
        case .TVshowgenreid(let genreId, let page):
            defaultParams.updateValue(genreId, forKey: "with_genres")
            defaultParams.updateValue(page, forKey: "page")
        case .searchMovie(let query, let page):
            defaultParams.updateValue(query, forKey: "query")
            defaultParams.updateValue(page, forKey: "page")
        case .TVshowPopular(let page):
            defaultParams.updateValue(page, forKey: "page")
        case .TVshowTopRate(let page):
            defaultParams.updateValue(page, forKey: "page")
        case .TVshowLastest(let page):
            defaultParams.updateValue(page, forKey: "page")
        case .TVshowDetail:
            defaultParams.updateValue("videos,credits,recommendations,reviews", forKey: "append_to_response")
        case .searchTVshow(let query, let page):
            defaultParams.updateValue(query, forKey: "query")
            defaultParams.updateValue(page, forKey: "page")
        case .personPopular(let page):
            defaultParams.updateValue(page, forKey: "page")
        case .personDetail:
            defaultParams.updateValue("movie_credits,images,tv_credits", forKey: "append_to_response")
        case .searchPerson(let query, let page):
            defaultParams.updateValue(query, forKey: "query")
            defaultParams.updateValue(page, forKey: "page")
        case .trendingMovie(let page):
            defaultParams.updateValue(page, forKey: "page")
        case .trendingTvShow(let page):
            defaultParams.updateValue(page, forKey: "page")
        case .getSimularMovie(_, let page):
            defaultParams.updateValue(page, forKey: "page")
        case .getSimularTv(_, let page):
            defaultParams.updateValue(page, forKey: "page")
        case .newMovie(let page):
            defaultParams.updateValue(page, forKey: "page")
        default:
            break
        }
        return defaultParams
    }
    
    var task: Task {
        switch self {
        case .upload(let params):
            var formData = [MultipartFormData]()
            for (key, value) in params {
                if let img = value as? UIImage {
                    let imgData = img.jpegData(compressionQuality: 0.5)!
                    formData.append(MultipartFormData(provider: .data(imgData), name: key, fileName: "testImage.jpg", mimeType: "image/jpeg"))
                } else if let imgData = value as? Data {
                    formData.append(MultipartFormData(provider: .data(imgData), name: key, fileName: "testImage.jpg", mimeType: "image/jpeg"))
                } else {
                    formData.append(MultipartFormData(provider: .data("\(value)".data(using: .utf8)!), name: key))
                }
            }
            return .uploadMultipart(formData)
        case .download(_, _):
            return .downloadDestination(downloadDestination)
        default:
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        }
    }
    
    var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }
    
    var localLocation: URL {
        switch self {
        case .download(let url, let fileName):
            let fileKey: String = url.md5
            let directory: URL = FileSystem.downloadDirectory
            var fileURL = directory.appendingPathComponent(fileKey)
            if let name = fileName {
                let pathExtension: String = (name as NSString).pathExtension.lowercased()
                fileURL = fileURL.appendingPathExtension(pathExtension)
            }
            return fileURL
        default:
            return URL(string: "")!
        }
    }
    
    var downloadDestination: DownloadDestination {
        return { _, _ in return (self.localLocation, [.removePreviousFile, .createIntermediateDirectories]) }
    }
}

class FileSystem {
    static let documentsDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.endIndex - 1]
    }()
    
    static let cacheDirectory: URL = {
        let urls = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        return urls[urls.endIndex - 1]
    }()

    static let downloadDirectory: URL = {
        let directory: URL = FileSystem.documentsDirectory.appendingPathComponent("/Download/")
        return directory
    }()
    
}
