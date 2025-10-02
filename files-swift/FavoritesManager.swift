// FavoritesManager.swift
import Foundation

class FavoritesManager {
    static let shared = FavoritesManager()
    private let favoritesKey = "favoriteDirectories"
    
    private var favorites: [String: String] {
        get {
            return UserDefaults.standard.dictionary(forKey: favoritesKey) as? [String: String] ?? [:]
        }
        set {
            UserDefaults.standard.set(newValue, forKey: favoritesKey)
        }
    }
    
    func addFavorite(path: String, name: String) {
        var currentFavorites = favorites
        currentFavorites[name] = path
        favorites = currentFavorites
    }
    
    func removeFavorite(name: String) {
        var currentFavorites = favorites
        currentFavorites.removeValue(forKey: name)
        favorites = currentFavorites
    }
    
    func getFavorites() -> [String: String] {
        return favorites
    }
    
    func isFavorite(path: String) -> Bool {
        return favorites.values.contains(path)
    }
}