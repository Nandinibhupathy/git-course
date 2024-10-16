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