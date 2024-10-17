import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class FileDatabase {

    private static final String DB_URL = "jdbc:mysql://localhost:3306/yourDatabase";
    private static final String DB_USER = "yourUsername";
    private static final String DB_PASSWORD = "yourPassword";

    public static void main(String[] args) {
        String fileName = "example.txt"; // Replace with the desired file name
        int fileId = getFileIdByName(fileName);

        if (fileId != -1) {
            System.out.println("File ID for '" + fileName + "' is: " + fileId);
        } else {
            System.out.println("File not found.");
        }
    }

    public static int getFileIdByName(String fileName) {
        String query = "SELECT id FROM files WHERE fileName = ?";
        try (Connection connection = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
             PreparedStatement statement = connection.prepareStatement(query)) {

            statement.setString(1, fileName);
            ResultSet resultSet = statement.executeQuery();

            if (resultSet.next()) {
                return resultSet.getInt("id");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1; // Return -1 if the file is not found
    }
}









import java.io.*;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.sql.*;

public class FileInserter {

    // Database credentials
    private static final String URL = "jdbc:mysql://localhost:3306/your_database"; // Update with your DB name
    private static final String USER = "your_username"; // Update with your DB username
    private static final String PASSWORD = "your_password"; // Update with your DB password

    public static void main(String[] args) {
        // Specify the path of the files to insert
        String directoryPath = "path/to/your/files"; // Change to your directory containing HTML, XML, and TXT files

        File directory = new File(directoryPath);
        File[] files = directory.listFiles((dir, name) -> name.toLowerCase().endsWith(".html")
                || name.toLowerCase().endsWith(".xml")
                || name.toLowerCase().endsWith(".txt"));

        if (files != null) {
            for (File file : files) {
                try {
                    insertFileIntoDatabase(file);
                    System.out.println("Inserted file: " + file.getName());
                } catch (IOException | SQLException e) {
                    System.err.println("Error inserting file: " + file.getName() + " - " + e.getMessage());
                }
            }
        } else {
            System.out.println("No files found in the directory.");
        }
    }

    // Insert file content into the database
    private static void insertFileIntoDatabase(File file) throws IOException, SQLException {
        String fileName = file.getName();
        String filePath = file.getAbsolutePath();
        String fileContent = new String(Files.readAllBytes(Paths.get(file.getAbsolutePath())));

        String sql = "INSERT INTO files (fileName, filePath, fileContent) VALUES (?, ?, ?)";

        try (Connection connection = DriverManager.getConnection(URL, USER, PASSWORD);
             PreparedStatement pstmt = connection.prepareStatement(sql)) {
            pstmt.setString(1, fileName);
            pstmt.setString(2, filePath);
            pstmt.setString(3, fileContent);
            pstmt.executeUpdate();
        }
    }
}











import java.io.*;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.sql.*;
import java.util.Scanner;

public class FileInserter {

    // Database credentials
    private static final String URL = "jdbc:mysql://localhost:3306/your_database";
    private static final String USER = "your_username";
    private static final String PASSWORD = "your_password";

    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        
        System.out.print("Enter the path of the file to insert: ");
        String filePath = scanner.nextLine(); // User input for file path

        try {
            insertFileIntoDatabase(filePath);
        } catch (IOException | SQLException e) {
            System.err.println("Error: " + e.getMessage());
        }
        
        scanner.close();
    }

    // Method to insert a file into the database
    public static void insertFileIntoDatabase(String filePath) throws IOException, SQLException {
        File file = new File(filePath);
        String fileName = file.getName();
        String content = readFileContent(filePath);
        
        // Insert file details into the database
        String sql = "INSERT INTO files (fileName, filePath, fileContent) VALUES (?, ?, ?)";
        
        try (Connection connection = DriverManager.getConnection(URL, USER, PASSWORD);
             PreparedStatement pstmt = connection.prepareStatement(sql)) {
            pstmt.setString(1, fileName);
            pstmt.setString(2, filePath);
            pstmt.setString(3, content);
            pstmt.executeUpdate();
            System.out.println("Inserted file: " + fileName);
        }
    }

    // Method to read the file content based on file type
    private static String readFileContent(String filePath) throws IOException {
        // Check the file extension to determine how to read it
        String fileExtension = getFileExtension(filePath);
        
        switch (fileExtension.toLowerCase()) {
            case "txt":
            case "xml":
                // For text and XML files, read them as plain text
                return new String(Files.readAllBytes(Paths.get(filePath)));
            case "docx":
                // For DOCX files, read as plain text (limitations apply)
                return readDocxFile(filePath);
            case "pdf":
                // For PDF files, read as byte stream and convert to string (limitations apply)
                return readPdfFile(filePath);
            default:
                throw new UnsupportedOperationException("Unsupported file type: " + fileExtension);
        }
    }

    // Method to read DOCX files as plain text (limited functionality)
    private static String readDocxFile(String filePath) throws IOException {
        // Treating DOCX as a text file, this will not give structured content
        return new String(Files.readAllBytes(Paths.get(filePath)));
    }

    // Method to read PDF files as a byte stream and convert to string
    private static String readPdfFile(String filePath) throws IOException {
        StringBuilder pdfText = new StringBuilder();
        // Read PDF file as bytes
        try (InputStream inputStream = new FileInputStream(filePath);
             ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream()) {
             
            byte[] buffer = new byte[1024];
            int bytesRead;
            while ((bytesRead = inputStream.read(buffer)) != -1) {
                byteArrayOutputStream.write(buffer, 0, bytesRead);
            }
            
            // Convert byte array to string (this will not yield structured text)
            byte[] pdfBytes = byteArrayOutputStream.toByteArray();
            return new String(pdfBytes); // Not recommended, just for demonstration
        }
    }

    // Helper method to get the file extension
    private static String getFileExtension(String filePath) {
        int lastIndexOfDot = filePath.lastIndexOf('.');
        if (lastIndexOfDot > 0 && lastIndexOfDot < filePath.length() - 1) {
            return filePath.substring(lastIndexOfDot + 1);
        }
        return "";
    }
}












import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;

public class FileUploader {

    // Database credentials
    private static final String URL = "jdbc:mysql://localhost:3306/your_database";
    private static final String USER = "your_username";
    private static final String PASSWORD = "your_password";

    public static void main(String[] args) {
        String filePath = "path/to/your/file.txt"; // Change this to your file's path
        uploadFile(filePath);
    }

    public static void uploadFile(String filePath) {
        File file = new File(filePath);

        try (FileInputStream fis = new FileInputStream(file);
             Connection connection = DriverManager.getConnection(URL, USER, PASSWORD)) {
            
            String sql = "INSERT INTO files (file_name, file_path, file_content) VALUES (?, ?, ?)";
            try (PreparedStatement pstmt = connection.prepareStatement(sql)) {
                pstmt.setString(1, file.getName());
                pstmt.setString(2, file.getAbsolutePath());
                pstmt.setBlob(3, fis); // Using setBlob to insert file content
                
                int rowsAffected = pstmt.executeUpdate();
                System.out.println("File uploaded successfully! Rows affected: " + rowsAffected);
            }
        } catch (SQLException e) {
            System.err.println("SQL Exception: " + e.getMessage());
        } catch (IOException e) {
            System.err.println("IO Exception: " + e.getMessage());
        }
    }
}











import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.sql.*;

public class FileHandler {
    private static final String URL = "jdbc:mysql://localhost:3306/yourDatabase";
    private static final String USER = "yourUsername";
    private static final String PASSWORD = "yourPassword";

    public static void main(String[] args) {
        try (Connection connection = DriverManager.getConnection(URL, USER, PASSWORD)) {
            String filePath = "/path/to/your/file.txt";
            String fileName = "file.txt";

            insertFile(connection, fileName, filePath);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private static void insertFile(Connection connection, String fileName, String filePath) throws SQLException, IOException {
        String insertQuery = "INSERT INTO Files (fileName, fileContent) VALUES (?, ?)";
        try (PreparedStatement preparedStatement = connection.prepareStatement(insertQuery);
             FileInputStream fis = new FileInputStream(new File(filePath))) {

            preparedStatement.setString(1, fileName);

            // Read the file into a byte array
            byte[] fileContent = fis.readAllBytes();
            preparedStatement.setBytes(2, fileContent);

            int rowsAffected = preparedStatement.executeUpdate();
            System.out.println(rowsAffected + " file(s) inserted successfully.");
        }
    }
}










import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;

public class InsertFileToBlob {

    public static void main(String[] args) {
        String url = "jdbc:mysql://localhost:3306/your_database"; // Replace with your database
        String user = "your_username"; // Replace with your MySQL username
        String password = "your_password"; // Replace with your MySQL password

        String filePath = "/path/to/your/file.pdf"; // Path to the file you want to insert

        Connection connection = null;
        PreparedStatement preparedStatement = null;

        try {
            // Step 1: Establish the connection
            connection = DriverManager.getConnection(url, user, password);
            System.out.println("Connected to the database.");

            // Step 2: Prepare the SQL query
            String sql = "INSERT INTO user_files (filename, file_data) VALUES (?, ?)";
            preparedStatement = connection.prepareStatement(sql);

            // Step 3: Set the file name and file data
            File file = new File(filePath);
            FileInputStream inputStream = new FileInputStream(file);
            preparedStatement.setString(1, file.getName());
            preparedStatement.setBinaryStream(2, inputStream, (int) file.length());

            // Step 4: Execute the query
            int row = preparedStatement.executeUpdate();
            System.out.println(row + " record(s) inserted.");

            // Close the input stream
            inputStream.close();
        } catch (SQLException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            // Step 5: Clean up
            try {
                if (preparedStatement != null) preparedStatement.close();
                if (connection != null) connection.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}












import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;

public class FileUploader {
    // Database connection parameters
    private static final String DB_URL = "jdbc:mysql://localhost:3306/your_database_name"; // Change to your database
    private static final String USER = "your_username"; // Change to your username
    private static final String PASSWORD = "your_password"; // Change to your password

    public static void main(String[] args) {
        String filePath = "path/to/your/example.txt"; // Change to the path of your file
        String fileName = "example.txt"; // Name of the file to be saved in the database

        try {
            // Upload file to database
            uploadFile(filePath, fileName);
            System.out.println("File uploaded successfully!");
        } catch (SQLException | IOException e) {
            e.printStackTrace();
        }
    }

    public static void uploadFile(String filePath, String fileName) throws SQLException, IOException {
        // Establish a database connection
        try (Connection connection = DriverManager.getConnection(DB_URL, USER, PASSWORD)) {
            // Prepare SQL statement for inserting the file
            String sql = "INSERT INTO files (filename, file_path, file_data) VALUES (?, ?, ?)";
            try (PreparedStatement preparedStatement = connection.prepareStatement(sql)) {
                // Set the filename and file path
                preparedStatement.setString(1, fileName);
                preparedStatement.setString(2, filePath);

                // Read file data as bytes
                File file = new File(filePath);
                byte[] fileData = new byte[(int) file.length()];

                try (FileInputStream fileInputStream = new FileInputStream(file)) {
                    fileInputStream.read(fileData);
                }

                // Set the file data as a BLOB
                preparedStatement.setBytes(3, fileData);

                // Execute the insert statement
                preparedStatement.executeUpdate();
            }
        }
    }
}