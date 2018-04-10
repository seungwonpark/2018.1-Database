package dbhw3;

import java.sql.*;
import java.util.*;

public class Hw3 {
	public static void main(String args[]) {
		String url = "jdbc:oracle:thin:@localhost:1521:orcl";
		String user = "veydpz"; // your DB user name
		String password = "root"; // your DB user password
	        
		try {
			Class.forName("oracle.jdbc.driver.OracleDriver");
			Connection conn = DriverManager.getConnection(url, user, password);
	       
			Scanner in = new Scanner(System.in);
			
			int isLogin = 0; // 0: not login, 1: student, 2: instructor
			
			PreparedStatement isStudent = conn.prepareStatement("select count(*) from student where ID = ? and Name = ?");
			PreparedStatement isInstructor = conn.prepareStatement("select count(*) from instructor where ID = ? and Name = ?");
			
			String id = "";
			String name = "";
			
			System.out.println("Welcome");
			
			while (true) { // 전체 프로그램을 언제 종료할지 모르겠어요...ㅋㅋ
				
				/* LOGIN */
				while (isLogin == 0) {
					System.out.println("\nPlease sign in");
					System.out.print("ID      : ");
					id = in.nextLine();
					System.out.print("Name    : ");
					name = in.nextLine();
					
					/* check student */
					isStudent.setString(1, id);
					isStudent.setString(2, name);
					ResultSet rs = isStudent.executeQuery();
					if (rs.next() && rs.getInt(1) == 1)  isLogin = 1;
					
					/* check instructor */
					isInstructor.setString(1, id);
					isInstructor.setString(2, name);
					rs = isInstructor.executeQuery();
					if (rs.next() && rs.getInt(1) == 1)  isLogin = 2;
					rs.close();	
					
					if (isLogin == 0)  System.out.println("\nWrong authentication");
				}
				
				/* after login */
				int menu = 3;
				if (isLogin == 1) { 
					/* student menu */
					while (true) {
						System.out.println("\nPlease select student menu");
						System.out.println("1) Student report");
						System.out.println("2) View time table");
						System.out.println("0) Exit");
						System.out.print(">> ");
						try {
							menu = Integer.parseInt(in.nextLine());
						} catch (NumberFormatException e) {}
						
						if (menu == 1) {
							/* student report */
							System.out.println("student report");
						} else if (menu == 2) {
							/* view time table */
							System.out.println("view time table");
						} else if (menu == 0) {
							isLogin = 0;
							break;
						}
					}
				} else if (isLogin == 2) {
					/* instructor menu */
					while (true) {
						System.out.println("\nPlease select instructor menu");
						System.out.println("1) Course report");
						System.out.println("2) Advisee report");
						System.out.println("0) Exit");
						System.out.print(">> ");
						try {
							menu = Integer.parseInt(in.nextLine());
						} catch (NumberFormatException e) {}
						
						
						if (menu == 1) {
							/* course report */
							System.out.println("Course report");
						} else if (menu == 2) {
							/* Advisee report */
							System.out.println("Advisee report");
						} else if (menu == 0) {
							isLogin = 0;
							break;
						}	
					}
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
}

