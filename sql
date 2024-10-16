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