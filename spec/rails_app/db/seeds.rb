FileRecord.delete_all

root = FileRecord.create(file_name: 'root', leaf: false)

file1 = FileRecord.create(file_name: 'file1', parent: root, size: 100)
file2 = FileRecord.create(file_name: 'file2', parent: root, size: 200)
dir3 = FileRecord.create(file_name: 'dir3', leaf: false, parent: root)

file11 = FileRecord.create(file_name: 'file11', parent: dir3, size: 1100)
dir12 = FileRecord.create(file_name: 'dir12', leaf: false, parent: dir3)

file111 = FileRecord.create(file_name: 'file111', parent: dir12, size: 11100)
