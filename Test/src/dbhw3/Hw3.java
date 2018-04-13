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
			PreparedStatement getStudentInfo = conn.prepareStatement("select * from student where ID = ?");
			PreparedStatement isInstructor = conn.prepareStatement("select count(*) from instructor where ID = ? and Name = ?");

			// be careful: "dept_name" is from "course" - not "student".
			// order in reverse time order. SQL does the static sort.
			PreparedStatement getGrade = conn.prepareStatement("select course_id, title, dept_name, credits, grade, semester, year from takes natural join course where ID = ? order by year desc, semester");
			PreparedStatement recentYearSemester = conn.prepareStatement("select section.semester, section.year, section.sec_id\n" +
					"from teaches join section on teaches.course_id = section.COURSE_ID\n" +
					"where ID = ? and section.year = (select max(teaches.year)\n" +
					"                      from teaches\n" +
					"                      where ID = ?)\n" + "order by case section.semester when 'Spring' then 1 when 'Summer' then 2 when 'Fall' then 3 when 'Winter' then 4 end desc");

			PreparedStatement recentCourses = conn.prepareStatement("select section.course_id, section.semester, section.building, section.ROOM_NUMBER, section.TIME_SLOT_ID, section.year\n" +
					"from teaches join section on teaches.course_id = section.COURSE_ID\n" +
					"where ID = ? and section.year = ? and section.semester = ? and section.sec_id = ?");

			PreparedStatement getTitle = conn.prepareStatement("select title from course where course_id = ?");
			PreparedStatement getTimeSlot = conn.prepareStatement("select * from time_slot where time_slot_id = ?");
			PreparedStatement getTakes = conn.prepareStatement("select ID, grade from takes where course_id = ? and semester = ? and year = ?");
			PreparedStatement getAdvisee = conn.prepareStatement("select ID, name, dept_name, tot_cred from"
					+ " student, advisor"
					+ " where student.ID = advisor.s_ID and ? = advisor.i_ID");


			String id = "";
			String name = "";

			System.out.println("Welcome");

			while (true) { // TODO: when should we terminate?
				/* login */
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
							/******************/
							/* student report */

							// basic information
							getStudentInfo.setString(1, id);
							ResultSet rs_studentinfo = getStudentInfo.executeQuery();
							rs_studentinfo.next();
							System.out.println(String.format("\nWelcome %s", name));
							System.out.println(String.format("You are a member of %s", rs_studentinfo.getString(3)));
							System.out.println(String.format("You have taken total %d credits", rs_studentinfo.getInt(4)));
							System.out.println("\nSemester report\n");

							getGrade.setString(1, id);
							ResultSet rs = getGrade.executeQuery();

							String prev_semester = "";
							int prev_year = 0;
							ArrayList<String> outputStorage = new ArrayList<String>();
							double sum_credits = 0;
							double sum_grades = 0;
							boolean isNull = false;

							while(rs.next()) {
								int credits = rs.getInt(4);
								String grade = rs.getString(5);
								if(grade == null) {
									grade = "0";
									isNull = true;
								}
								String semester = rs.getString(6);
								int year = rs.getInt(7);

								if(!prev_semester.equals(semester) || prev_year != year) {
									if(prev_year != 0) {
										double gpa = sum_grades * 1.0 / sum_credits;
										System.out.print(String.format("%d\t%s\tGPA : ", prev_year, prev_semester));
										if(!isNull) {
											System.out.print(String.format("%.5f", gpa));
										}
										System.out.println("\ncourse_id\ttitle\tdept_name\tcredits\tgrade");
										for(String temp : outputStorage) {
											System.out.println(temp);
										}
										System.out.println("");
										isNull = false;
									}

									prev_semester = semester;
									prev_year = year;

									// initialize after flushing
									outputStorage = new ArrayList<String>();
									sum_credits = 0;
									sum_grades = 0;
								}

								String inner = "";
								for(int i=1; i<=5; i++) {
									// course_id, title, dept_name, credits, grade

									// if null, then don't write credits, grade.
									if(isNull && (i == 4 || i == 5)) continue;
									inner += String.format("%s\t", rs.getString(i));
								}
								outputStorage.add(inner);
								sum_credits += credits;
								sum_grades += credits * grade2num(grade);

							}

							// flush output once more
							double gpa = sum_grades * 1.0 / sum_credits;
							System.out.print(String.format("%d\t%s\tGPA : ", prev_year, prev_semester));
							if(!isNull) {
								System.out.print(String.format("%.5f", gpa));
							}
							System.out.println("\ncourse_id\ttitle\tdept_name\tcredits\tgrade");
							for(String temp : outputStorage) {
								System.out.println(temp);
							}
							System.out.println("");
							/* end student report */
							/**********************/
						} else if (menu == 2) {
							/******************/
							/* time table */
							Statement stmt = conn.createStatement(
									ResultSet.TYPE_SCROLL_INSENSITIVE,
									ResultSet.CONCUR_READ_ONLY
							);
							ResultSet ys = stmt.executeQuery("select distinct semester, year from takes where ID="+ id + " order by year desc, case semester when 'Spring' then 1 when 'Summer' then 2 when 'Fall' then 3 when 'Winter' then 4 end desc");
							System.out.println("\nPlease select semester to view");
							int index = 1;
							while (ys.next()) {
								System.out.println(index + ") " + ys.getInt(2) + " " + ys.getString(1));
								index++;
							}
							try {
								int selectedIndex = Integer.parseInt(in.nextLine());
								ys.absolute(selectedIndex);
							} catch (NumberFormatException e) {}
							ResultSet tt = stmt.executeQuery("select course_id, title, day, start_hr, start_min, end_hr, end_min " +
									"from course C, time_slot T " +
									"where (C.course_id, T.time_slot_id) in (select course_id, time_slot_id from takes natural join section " +
									"where takes.ID="+ id + " and semester='" + ys.getString(1) + "' and year=" + ys.getInt(2)+ ")");
							System.out.println("\ncourse_id\ttitle\tday\tstart_time\tend_time");
							while(tt.next()) {
								System.out.println(tt.getString(1) + "\t" + tt.getString(2) + "\t" + tt.getString(3) + "\t" + tt.getInt(4) + " : " +tt.getInt(5) + "\t" + tt.getInt(6) + " : " + tt.getInt(7));
							}
							stmt.close();

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
							recentYearSemester.setString(1, id);
							recentYearSemester.setString(2, id);
							ResultSet rs = recentYearSemester.executeQuery();
							rs.next();
							String recent_semester = rs.getString(1);
							String recent_year = rs.getString(2);
							String recent_sec_id = rs.getString(3);

							recentCourses.setString(1, id);
							recentCourses.setString(2, recent_year);
							recentCourses.setString(3, recent_semester);
							recentCourses.setString(4, recent_sec_id);
							ResultSet rs1 = recentCourses.executeQuery();


							while(rs1.next()) {
								String course_id = rs1.getString(1);
								String semester = rs1.getString(2);
								String building = rs1.getString(3);
								String room = rs1.getString(4);
								String timeslot = rs1.getString(5);
								String year = rs1.getString(6);

								getTitle.setString(1, course_id);
								ResultSet rs2 = getTitle.executeQuery();
								rs2.next();
								String title = rs2.getString(1);

								getTimeSlot.setString(1, timeslot);
								ResultSet rs3 = getTimeSlot.executeQuery();
								rs3.next();
								String day = rs3.getString(2);
								String s_hr = rs3.getString(3);
								String s_min = rs3.getString(4);
								String e_hr = rs3.getString(5);
								String e_min = rs3.getString(6);

								System.out.print(course_id + " " + title + "\t[" + building + " " + room + "] ");

								System.out.print("(" + day);

								while (rs3.next()) {
									day = rs3.getString(2);
									System.out.print(", " + day);
								}
								System.out.println(" " + s_hr + " : " + s_min + " - " + e_hr + " : " + e_min + ")");
								System.out.println("ID\tname\tdept_name\tgrade");

								getTakes.setString(1, course_id);
								getTakes.setString(2, recent_semester);
								getTakes.setString(3, year);
								ResultSet rs4 = getTakes.executeQuery();
								while (rs4.next()) {
									String student_id = rs4.getString(1);
									String grade = rs4.getString(2);

									getStudentInfo.setString(1, student_id);
									ResultSet rs5 = getStudentInfo.executeQuery();
									rs5.next();
									String student_name = rs5.getString(2);
									String student_dept = rs5.getString(3);

									System.out.println(student_id + "\t" + student_name + "\t" + student_dept + "\t" + grade);
								}
								System.out.println();
							}

						} else if (menu == 2) {
							/******************/
							/* Advisee report */

							getAdvisee.setString(1, id);
							ResultSet rs = getAdvisee.executeQuery();

							System.out.println("ID\tname\tdept_name\ttot_cred");
							String result = "";
							while (rs.next()) {
								String s_id = rs.getString(1);
								String s_name = rs.getString(2);
								String s_dept_name = rs.getString(3);
								int s_tot_cred = rs.getInt(4);
								result += s_id + "\t" + s_name + "\t" + s_dept_name + "\t" + s_tot_cred + "\n";
							}
							System.out.print(result);
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


	public static double grade2num(String grade) {
		// grade -> num
		// grade2num("A+") = 43
		// grade2num("A") = 40
		char alphabet = grade.charAt(0);
		if(alphabet == 'F') return 0;
		else {
			grade = grade.concat("0"); // concatenate string for convenience
			int alphabet_ascii = (int) alphabet;
			int ret = 10 * (69 - alphabet_ascii);
			char sign = grade.charAt(1); // +, 0, -
			switch(sign) {
				case '+':
					ret += 3;
					break;
				case '0':
					ret += 0;
					break;
				case '-':
					ret -= 3;
					break;
			}
			return ret * 0.1;
		}
	}
}

