//
//  CardEditorTagSuggestPanel.swift
//  PRO100_Карточки
//

import UIKit

final class CardEditorTagSuggestPanel: UIView {
    var onPick: ((String) -> Void)?
    var tagsAlreadyOnCard: () -> [String] = { [] }
    var onNeedsLayoutUpdate: (() -> Void)?

    private let tableView = UITableView(frame: .zero, style: .plain)
    private var allTags: [APITag] = []
    private var filteredTags: [APITag] = []
    private var filterTrimmed: String = ""
    private var isLoading = true

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .secondarySystemGroupedBackground
        layer.cornerRadius = 8
        layer.borderWidth = 1
        layer.borderColor = UIColor.separator.cgColor
        clipsToBounds = true

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        tableView.backgroundColor = .clear
        tableView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func prepareForDisplay() {
        guard isLoading else {
            applyFilterAndReload()
            return
        }
        StudyContentService.shared.fetchTags { [weak self] result in
            guard let self else { return }
            self.isLoading = false
            switch result {
            case .success(let list):
                self.allTags = list
            case .failure:
                self.allTags = []
            }
            self.applyFilterAndReload()
        }
    }

    func setFilterText(_ raw: String) {
        filterTrimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        applyFilterAndReload()
    }

    func preferredHeight(maxHeight: CGFloat = 220) -> CGFloat {
        let rowH: CGFloat = 44
        let count = CGFloat(rowCount())
        return min(maxHeight, max(rowH, count * rowH + 2))
    }

    private func pickedNamesLowercased() -> Set<String> {
        Set(tagsAlreadyOnCard().map { $0.lowercased() })
    }

    private var showCreateRow: Bool {
        guard !filterTrimmed.isEmpty else { return false }
        if pickedNamesLowercased().contains(filterTrimmed.lowercased()) { return false }
        let exactExists = allTags.contains { $0.name.caseInsensitiveCompare(filterTrimmed) == .orderedSame }
        return !exactExists
    }

    private func applyFilterAndReload() {
        let picked = pickedNamesLowercased()
        let available = allTags.filter { !picked.contains($0.name.lowercased()) }
        if filterTrimmed.isEmpty {
            filteredTags = available.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        } else {
            filteredTags = available
                .filter { $0.name.localizedCaseInsensitiveContains(filterTrimmed) }
                .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        }
        tableView.reloadData()
        let approxHeight = CGFloat(rowCount()) * 44
        tableView.isScrollEnabled = approxHeight > 200
        onNeedsLayoutUpdate?()
    }

    private func rowCount() -> Int {
        if isLoading { return 1 }
        let n = (showCreateRow ? 1 : 0) + filteredTags.count
        return n > 0 ? n : 1
    }
}

extension CardEditorTagSuggestPanel: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rowCount()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.font = .preferredFont(forTextStyle: .body)
        cell.backgroundColor = .clear
        cell.accessoryType = .none

        if isLoading {
            cell.textLabel?.text = "Загрузка…"
            cell.textLabel?.textColor = .secondaryLabel
            cell.selectionStyle = .none
            return cell
        }

        let n = (showCreateRow ? 1 : 0) + filteredTags.count
        if n == 0 || (filteredTags.isEmpty && !showCreateRow) {
            cell.textLabel?.text = "Нет тегов. Введите новое имя и нажмите «Добавить»."
            cell.textLabel?.textColor = .secondaryLabel
            cell.selectionStyle = .none
            return cell
        }

        cell.textLabel?.textColor = .label
        cell.selectionStyle = .default

        let createFirst = showCreateRow
        if createFirst && indexPath.row == 0 {
            cell.textLabel?.text = "Новый тег: «\(filterTrimmed)»"
            return cell
        }
        let tagIndex = indexPath.row - (createFirst ? 1 : 0)
        guard filteredTags.indices.contains(tagIndex) else {
            cell.textLabel?.text = ""
            return cell
        }
        cell.textLabel?.text = filteredTags[tagIndex].name
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if isLoading { return }
        let n = (showCreateRow ? 1 : 0) + filteredTags.count
        if n == 0 || (filteredTags.isEmpty && !showCreateRow) { return }

        let createFirst = showCreateRow
        if createFirst && indexPath.row == 0 {
            onPick?(filterTrimmed)
            return
        }
        let tagIndex = indexPath.row - (createFirst ? 1 : 0)
        guard filteredTags.indices.contains(tagIndex) else { return }
        onPick?(filteredTags[tagIndex].name)
    }
}
