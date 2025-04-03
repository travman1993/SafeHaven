//
//  Untitled.swift
//  SafeHaven
//
//  Created by Travis Rodriguez on 4/3/25.
//
import SwiftUI

// MARK: - Digital ID Storage Card
struct DigitalIDStorageCard: View {
    @State private var showingDocumentGallery = false
    
    var body: some View {
        Button(action: {
            showingDocumentGallery = true
        }) {
            VStack(alignment: .leading, spacing: ResponsiveLayout.padding(12)) {
                HStack {
                    Image(systemName: "doc.text.fill")
                        .font(.system(size: ResponsiveLayout.fontSize(24)))
                        .foregroundColor(AppTheme.primary)
                    
                    Text("Document Storage")
                        .font(.system(size: ResponsiveLayout.fontSize(18), weight: .semibold))
                        .foregroundColor(AppTheme.adaptiveTextPrimary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(AppTheme.adaptiveTextSecondary)
                }
                
                Text("Securely store important documents offline")
                    .font(.system(size: ResponsiveLayout.fontSize(14)))
                    .foregroundColor(AppTheme.adaptiveTextSecondary)
                    .padding(.top, 2)
                
                HStack(spacing: ResponsiveLayout.padding(12)) {
                    Feature(icon: "camera.fill", text: "Take a photo")
                    Feature(icon: "lock.fill", text: "Store on-device only")
                    Feature(icon: "doc.text.magnifyingglass", text: "Organize & search")
                }
                .padding(.top, 8)
            }
            .padding(ResponsiveLayout.padding())
            .background(AppTheme.adaptiveCardBackground)
            .cornerRadius(ResponsiveLayout.isIPad ? 20 : 16)
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
        }
        .sheet(isPresented: $showingDocumentGallery) {
            DigitalIDGalleryView()
        }
    }
    
    private struct Feature: View {
        let icon: String
        let text: String
        
        var body: some View {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: ResponsiveLayout.fontSize(12)))
                    .foregroundColor(AppTheme.primary)
                
                Text(text)
                    .font(.system(size: ResponsiveLayout.fontSize(12)))
                    .foregroundColor(AppTheme.adaptiveTextSecondary)
            }
        }
    }
}

// Digital ID Gallery View
struct DigitalIDGalleryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingCamera = false
    @State private var documents: [StoredDocument] = []
    @State private var newImage: UIImage?
    @State private var showingLabelSheet = false
    
    // Mock data - would be replaced with actual document storage
    struct StoredDocument: Identifiable {
        let id = UUID()
        let name: String
        let type: String
        let image: UIImage?
        let date: Date
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.adaptiveBackground.ignoresSafeArea()
                
                VStack {
                    if documents.isEmpty {
                        emptyStateView
                    } else {
                        documentListView
                    }
                }
                .navigationTitle("Digital ID Storage")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Close") {
                            dismiss()
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showingCamera = true
                        }) {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
        }
        .onAppear {
            // Load example documents for demonstration
            if documents.isEmpty {
                documents = [
                    StoredDocument(name: "Driver's License", type: "ID", image: nil, date: Date()),
                    StoredDocument(name: "Health Insurance", type: "Insurance", image: nil, date: Date())
                ]
            }
        }
        .sheet(isPresented: $showingCamera) {
            Text("Camera View Placeholder")
                .font(.title)
                .padding()
            // In a real implementation, this would be a camera view or image picker
        }
        .sheet(isPresented: $showingLabelSheet) {
            if newImage != nil {
                DocumentLabelingView(image: newImage!, onSave: { name, type in
                    let newDoc = StoredDocument(name: name, type: type, image: newImage, date: Date())
                    documents.append(newDoc)
                    newImage = nil
                })
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: ResponsiveLayout.padding(20)) {
            Image(systemName: "creditcard.fill")
                .font(.system(size: ResponsiveLayout.fontSize(60)))
                .foregroundColor(AppTheme.primary.opacity(0.5))
                .padding(.bottom, ResponsiveLayout.padding(20))
            
            Text("No Documents Yet")
                .font(.system(size: ResponsiveLayout.fontSize(20), weight: .semibold))
                .foregroundColor(AppTheme.adaptiveTextPrimary)
            
            Text("Add your first document by taking a photo or uploading an image")
                .font(.system(size: ResponsiveLayout.fontSize(16)))
                .foregroundColor(AppTheme.adaptiveTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, ResponsiveLayout.padding(20))
            
            Button(action: {
                showingCamera = true
            }) {
                HStack {
                    Image(systemName: "camera.fill")
                    Text("Add Document")
                }
                .padding()
                .background(AppTheme.primary)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .padding(.top, ResponsiveLayout.padding(20))
        }
        .padding()
    }
    
    private var documentListView: some View {
        List {
            ForEach(documents) { document in
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(AppTheme.primary.opacity(0.1))
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: "doc.text.fill")
                            .foregroundColor(AppTheme.primary)
                    }
                    
                    VStack(alignment: .leading) {
                        Text(document.name)
                            .font(.headline)
                            .foregroundColor(AppTheme.adaptiveTextPrimary)
                        
                        HStack {
                            Text(document.type)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(AppTheme.primary.opacity(0.1))
                                .cornerRadius(4)
                            
                            Spacer()
                            
                            Text(document.date, style: .date)
                                .font(.caption)
                                .foregroundColor(AppTheme.adaptiveTextSecondary)
                        }
                    }
                    .padding(.leading, 8)
                }
                .padding(.vertical, 4)
            }
            .onDelete { indexSet in
                documents.remove(atOffsets: indexSet)
            }
        }
    }
}

// Document Labeling View
struct DocumentLabelingView: View {
    @Environment(\.dismiss) private var dismiss
    let image: UIImage
    let onSave: (String, String) -> Void
    
    @State private var documentName = ""
    @State private var documentType = "ID"
    
    let documentTypes = ["ID", "Insurance", "Medical", "Financial", "Veteran", "Other"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Document Image")) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                }
                
                Section(header: Text("Document Details")) {
                    TextField("Document Name", text: $documentName)
                    
                    Picker("Document Type", selection: $documentType) {
                        ForEach(documentTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                }
            }
            .navigationTitle("Label Document")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave(documentName, documentType)
                        dismiss()
                    }
                    .disabled(documentName.isEmpty)
                }
            }
        }
    }
}
