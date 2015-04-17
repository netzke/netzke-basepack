# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

FileRecord.delete_all

root = FileRecord.create(name: 'root', is_dir: true)

file1 = FileRecord.create(name: 'file1', parent: root, size: 100)
file2 = FileRecord.create(name: 'file2', parent: root, size: 200)
dir3 = FileRecord.create(name: 'dir3', is_dir: true, parent: root)

file11 = FileRecord.create(name: 'file11', parent: dir3, size: 1100)
dir12 = FileRecord.create(name: 'dir12', is_dir: true, parent: dir3)

file111 = FileRecord.create(name: 'file111', parent: dir12, size: 11100)
