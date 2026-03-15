import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(statusCode: Int)
    case serverErrorWithMessage(statusCode: Int, message: String)
    case decodingError
    case encodingError
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL endpoint tidak valid."
        case .invalidResponse:
            return "Respons server tidak valid."
        case .serverError(let statusCode):
            switch statusCode {
            case 401:
                return "Sesi Anda sudah berakhir. Silakan masuk lagi."
            case 403:
                return "Anda tidak memiliki akses untuk melakukan aksi ini."
            case 404:
                return "Data yang diminta tidak ditemukan."
            case 409:
                return "Data yang Anda kirim bertabrakan dengan data yang sudah ada."
            case 422:
                return "Data yang dikirim belum valid."
            case 500...599:
                return "Server sedang bermasalah. Coba lagi beberapa saat."
            default:
                return "Terjadi kesalahan pada server."
            }
        case .serverErrorWithMessage(_, let message):
            return message
        case .decodingError:
            return "Data dari server tidak dapat dibaca."
        case .encodingError:
            return "Permintaan tidak dapat diproses."
        case .unknown:
            return "Terjadi kesalahan yang tidak diketahui."
        }
    }
}
