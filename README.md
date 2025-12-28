


# 📦 Bash DBMS – Command Line Database Management System

<p align="center">
  <img src="https://readme-typing-svg.herokuapp.com?size=28&duration=4000&color=00E5FF&center=true&vCenter=true&width=700&lines=Shell+Script+DBMS;Mini+Database+Management+System;Built+with+Bash+%F0%9F%90%9A" />
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Bash-Scripting-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white"/>
  <img src="https://img.shields.io/badge/Linux-Compatible-black?style=for-the-badge&logo=linux"/>
  <img src="https://img.shields.io/badge/CLI-Interactive-blue?style=for-the-badge"/>
  <img src="https://img.shields.io/badge/Status-Completed-success?style=for-the-badge"/>
</p>

---

## 🧠 About The Project

**Bash DBMS** is a fully interactive **Database Management System built using pure Bash scripting**.
It simulates core DBMS functionalities such as database creation, table management, data insertion, querying, updating, and deletion — **without using any external DB engines**.

---

## ✨ Key Features

### 🗄️ Database Operations

* ✅ Create Database
* 📋 List Databases
* 🔌 Connect to Database
* ❌ Drop Database (with confirmation)

### 📊 Table Operations

* ➕ Create Table (with metadata & primary key)
* 📄 List Tables
* ❌ Drop Table
* ✏️ Insert Records
* 🔍 Select Records
* 🗑️ Delete Records
* 🔄 Update Records

### 🛡️ Data Integrity & Validation

* Primary Key enforcement
* Data type validation (`int` / `str`)
* Unique primary key check
* Input sanitization
* Safe delete confirmations

### 🎨 User Interface

* Colorful CLI menus 🌈
* Box-styled UI
* Interactive select menus
* Clear error & success messages

---

## 🧩 Project Structure

```
DBMS/
│
├── main.sh
│
├── db_ops/
│   ├── create_db.sh
│   ├── list_db.sh
│   ├── connect_db.sh
│   └── drop_db.sh
│
├── table_ops/
│   ├── create_table.sh
│   ├── list_table.sh
│   ├── insert_table.sh
│   ├── select_from_table.sh
│   ├── update_table.sh
│   ├── delete_fromtable.sh
│   └── drop_table.sh
│
└── databases/
    └── (auto-created databases & tables)
```

---

## 🖥️ Main Menu Preview

```
╔══════════════════════════════════╗
║            DBMS                  ║
╠══════════════════════════════════╣
║  1) Create Database              ║
║  2) List Databases               ║
║  3) Connect to Database          ║
║  4) Drop Database                ║
║  5) Exit                         ║
╚══════════════════════════════════╝
```

---

### 🗂️ Main Menu (Database-Level Operations)

When the system starts, the user is presented with the main menu, which allows management of databases.
Each database is implemented as a **directory** inside the system storage.

* **Create Database**: Creates a new database by generating a dedicated directory after validating the database name and ensuring it does not already exist.

* **List Databases**: Displays all available databases by listing existing database directories.

* **Connect to Database**: Allows the user to select and connect to a specific database, enabling table-level operations within that database context.

* **Drop Database**: Permanently removes a selected database directory along with all tables stored inside it, after user confirmation.

---

### 🗂️ Database Menu Preview

```
╔══════════════════════════════════╗
║      Connected Database: mydb    ║
╠══════════════════════════════════╣
║ 1️⃣  Create Table                 ║
║ 2️⃣  List Tables                  ║
║ 3️⃣  Drop Table                   ║
║ 4️⃣  Insert Into Table            ║
║ 5️⃣  Select From Table            ║
║ 6️⃣  Delete From Table            ║
║ 7️⃣  Update Table                 ║
║ 8️⃣  Exit to Main Menu             ║
╚══════════════════════════════════╝
```

---

### 📊 Database Operations (After Connecting)

Once connected to a database, the system switches to table-level management.
Each table is stored as a **data file**, with a corresponding **metadata file** that defines its schema.

* **Create Table**: Creates a new table by defining column names, data types, and a primary key.
  The table structure is stored in a metadata file, while the actual records are stored separately.

* **List Tables**: Lists all tables available in the connected database by scanning the database directory.

* **Drop Table**: Deletes a specified table and its associated metadata file from the database.

* **Insert Into Table**: Inserts a new row into a table after validating:

  * Data types
  * Column count
  * Primary key uniqueness

* **Select From Table**: Retrieves and displays data from a table.
  Supports selecting all records or filtering data based on column values.

* **Delete From Table**: Removes specific records from a table based on a matching condition, ensuring safe and controlled deletion.

* **Update Table**: Modifies existing records in a table by updating one or more column values that satisfy a given condition.

---

## 🧪 Table Design Logic

* Each table has:

  * `.table` file → stores actual data
  * `metaData_<table>` → stores schema

### Metadata Example

```
Table Name: students
Columns: 3
primary_key:id:int
column:name:str
column:age:int
```

### Data File Example

| id | name  | age |
| -- | ----- | --- |
| 1  | Alice | 21  |
| 2  | Bob   | 22  |
| 3  | Carol | 20  |

---

## 🚀 How To Run

### 1️⃣ Clone the Repository

```bash
git clone https://github.com/jannawaelali-creator/DBMS.git
cd DBMS
```

### 2️⃣ Give Execute Permission

```bash
chmod +x *.sh db_ops/*.sh table_ops/*.sh
```

### 3️⃣ Run the DBMS

```bash
./main.sh
```

---

## 🛠️ Technologies Used

* 🐧 Linux
* 🧾 Bash Scripting
* 📁 File System as Storage
* 🧠 AWK / SED / GREP
* 🎨 ANSI Escape Codes

---

## 🌱 Future Enhancements

* 🔐 User authentication
* 🧮 Aggregate functions (COUNT, SUM)
* 📑 Export to CSV
* 🧠 Indexing for faster search
* 🧪 Automated testing scripts

---





## 👩‍💻 Author

* **Janna Wael** – ITI student, Cloud Platform Development track
* **Nourhan Ahmed** – ITI student, Cloud Platform Development track

---





