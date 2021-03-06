//
//  VocabularyStore.swift
//  Gardener
//
//  Created by Stefan Cimander on 24.06.20.
//

import Firebase
import FirebaseFirestoreSwift

///
/// Vocabulary store for loading, adding and deleting vocabulary
/// entries saved in the Firebase Firestore database.
///
class VocabularyStore: ObservableObject {
    
    @Published
    var vocabulary: [Vocabulary] = []
    
    private let listsCollection = Firestore.firestore().collection("lists")

    ///
    /// Loads all vocabulary entries for the list with a given id.
    /// Further, loaded entries are automatically updated and kept in sync
    /// whenever there is a change within the specified vocabulary list.
    ///
    /// - Parameter listId: The id of the list to load all vocabulary entries for.
    ///
    func loadAll(for listId: String) {
        let collection = listsCollection.document(listId).collection("vocabulary").order(by: "createdAt", descending: true)
        collection.addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                print("Could not load vocabulary entries from list with id \(listId) - \(error.localizedDescription)")
                return
            }
            guard let snapshot = querySnapshot else { return }
            self.vocabulary = snapshot.documents.compactMap(self.toVocabulary)
        }
    }
    
    ///
    /// Adds a new vocabulary entry to the list with a given id.
    ///
    /// - Parameter vocabulary: The new vocabulary entry to add to the list.
    /// - Parameter listId: The id of the list to add the vocabulary entry to.
    ///
    func add(_ vocabulary: Vocabulary, to listId: String) {
        do {
            let collection = listsCollection.document(listId).collection("vocabulary")
            let _ = try collection.addDocument(from: vocabulary)
        } catch {
            print("Could not add vocabulary \(vocabulary.foreignName) to list with id \(listId) - \(error.localizedDescription)")
        }
    }
    
    
    ///
    /// Deletes vocabulary entries at certain offsets from the list with a given id.
    ///
    /// - Parameter offsets: Index set containing offsets of vocabulary entries to delete.
    /// - Parameter listId: The id of the list to delete the vocabulary entries from.
    ///
    func delete(at offsets: IndexSet, from listId: String) {
        let collection = listsCollection.document(listId).collection("vocabulary")
        let allIds = vocabulary.compactMap(\.id)
        vocabulary.remove(atOffsets: offsets)
        
        let remainingIds = vocabulary.compactMap(\.id)
        let deletedIds = allIds.filter { !remainingIds.contains($0) }
        
        deletedIds.forEach { collection.document($0).delete() }
    }
    
    
    private func toVocabulary(snapshot: QueryDocumentSnapshot) -> Vocabulary? {
        do {
            return try snapshot.data(as: Vocabulary.self)
        } catch {
            print("Could not parse snapshot data \(snapshot.data()) as vocabulary instance - \(error.localizedDescription)")
            return nil
        }
    }
    
}
