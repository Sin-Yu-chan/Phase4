package Phase4;

import java.sql.*;

public class DBConnection {
    //DB 환경에 맞게 아래 정보를 수정하세요.
    private static final String DB_URL = "jdbc:oracle:thin:@localhost:1521:orcl"; 
    private static final String DB_USER = "testcase";   // 아이디
    private static final String DB_PW = "testcase";      // 비밀번호

    public static Connection getConnection() {
        Connection conn = null;
        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PW);
        } catch (ClassNotFoundException e) {
            System.out.println("❌ JDBC 드라이버 로드 실패");
            e.printStackTrace();
        } catch (SQLException e) {
            System.out.println("❌ DB 연결 실패 (ID/PW 확인 필요)");
            e.printStackTrace();
        }
        return conn;
    }

    public static void close(Connection conn) {
        try {
            if (conn != null && !conn.isClosed()) {
                conn.close();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}