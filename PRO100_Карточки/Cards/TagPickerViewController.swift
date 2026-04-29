//
//  TagPickerViewController.swift
//  PRO100_Карточки
//

import UIKit

/// Выбор тега для фильтра: список с прокруткой и поиском (GET /api/tags?search=).
final class TagPickerViewController: UIViewController {
    var onPick: ((APITag?) -> Void)?
    var selectedName: String?

    private let searchBar = UISearchBar()
    private let tableView = UITableView(frame: .zero, style: .plain)
    private var tags: [APITag] = []
    private var searchWorkItem: DispatchWorkItem?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Теги"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Отмена",
            style: .plain,
            target: self,
            action: #selector(cancelTapped)
        )

        searchBar.placeholder = "Поиск по названию"
        searchBar.searchBarStyle = .minimal
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.keyboardDismissMode = .onDrag
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 4),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        loadTags(search: nil)
    }

    @objc private func cancelTapped() {
        dismiss(animated: true)
    }

    private func loadTags(search: String?) {
        StudyContentService.shared.fetchTags(search: search) { [weak self] result in
            guard let self else { return }
            switch result {
            case .failure(let e):
                self.tags = []
                self.tableView.reloadData()
                self.showTopBanner(e.localizedDescription)
            case .success(let list):
                self.tags = list
                self.tableView.reloadData()
            }
        }
    }

    private func applyAndDismiss(_ tag: APITag?) {
        dismiss(animated: true) {
            self.onPick?(tag)
        }
    }

    private func rowTag(at indexPath: IndexPath) -> APITag? {
        guard indexPath.section == 1 else { return nil }
        guard tags.indices.contains(indexPath.row) else { return nil }
        return tags[indexPath.row]
    }
}

extension TagPickerViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchWorkItem?.cancel()
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let work = DispatchWorkItem { [weak self] in
            self?.loadTags(search: trimmed.isEmpty ? nil : trimmed)
        }
        searchWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: work)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension TagPickerViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int { 2 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? 1 : tags.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? nil : (tags.isEmpty ? "Нет тегов" : nil)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.accessoryType = .none
        if indexPath.section == 0 {
            cell.textLabel?.text = "Все теги"
            cell.textLabel?.font = .preferredFont(forTextStyle: .body)
            let on = selectedName == nil || selectedName?.isEmpty == true
            cell.accessoryType = on ? .checkmark : .none
            return cell
        }
        let tag = tags[indexPath.row]
        cell.textLabel?.text = tag.name
        cell.textLabel?.font = .preferredFont(forTextStyle: .body)
        if tag.name == selectedName {
            cell.accessoryType = .checkmark
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            applyAndDismiss(nil)
            return
        }
        guard let t = rowTag(at: indexPath) else { return }
        applyAndDismiss(t)
    }
}
