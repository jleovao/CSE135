<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    import="java.sql.*" pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
  <%
  session.removeAttribute("name");
  session.removeAttribute("role");
  %>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
    <title>Login Page</title>
  </head>
  <body>
    <h1>Login Page</h1>
    <form>
      <input type="hidden" name="action" value="select">
      Name:<input type="text" name="name">
      <input type="submit" value="Login">
    </form>
        
    <%
    String action = request.getParameter("action");
    String name=null;
    String role=null;
    Connection conn=null;
    Statement stmt=null;
    ResultSet rs=null;

    try{
        Class.forName("org.postgresql.Driver");
        conn = DriverManager.getConnection(
          "jdbc:postgresql://localhost:5432/shopping?" +
          "user=postgres&password=Ineas710");
        if(action!=null && action.equals("select")){
          stmt=conn.createStatement();
          try {
            name=request.getParameter("name");
          }catch(Exception e){name=null;}
          rs=stmt.executeQuery("SELECT * FROM users where name='"+name+"';");
          if(rs.next()) {
            role=rs.getString(2);
            session.setAttribute("name", name);
            session.setAttribute("role",role);
            response.sendRedirect("/CSE135/home");
          }
          else{
            if(name!=null && !name.equals("")){
              out.println("<br>***Provided name, "+name+", was not found");
            }
            else{
              out.println("<br>***Provide a name to login");
            }
          }
        }
        conn.close();
    }catch(SQLException e){
      throw new RuntimeException(e);
    }
    finally{
      if (stmt != null) {
        try {
          stmt.close();
        } catch (SQLException e) { } // Ignore
      stmt = null;
      }
      if (conn != null) {
        try {
          conn.close();
        } catch (SQLException e) { } // Ignore
        conn = null;
      }
    }   
    %>
    
    <br>
    <a href="/CSE135/signup">New User?</a>
  </body>
</html>