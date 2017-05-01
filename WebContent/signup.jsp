<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    import="java.sql.*" pageEncoding="ISO-8859-1"%>

<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
    <title>Signup Page</title>
  </head>
  <body>
    <h1>Signup Page</h1>
    <form>
      <input type="hidden" name="action" value="insert">
      Name:<input type="text" name="name"><br>
      Role:<select name="role">
        <option value="">Role</option>
        <option value="customer">Customer</option>
        <option value="owner">Owner</option>
      </select><br>
      Age:<input type="number" name="age" min="0" max="999"><br>
      State:<select name="state">
        <option value="">State</option>
        <option value="AL">Alabama</option>
        <option value="AK">Alaska</option>
        <option value="AZ">Arizona</option>
        <option value="AR">Arkansas</option>
        <option value="CA">California</option>
        <option value="CO">Colorado</option>
        <option value="CT">Connecticut</option>
        <option value="DE">Delaware</option>
        <option value="DC">District Of Columbia</option>
        <option value="FL">Florida</option>
        <option value="GA">Georgia</option>
        <option value="HI">Hawaii</option>
        <option value="ID">Idaho</option>
        <option value="IL">Illinois</option>
        <option value="IN">Indiana</option>
        <option value="IA">Iowa</option>
        <option value="KS">Kansas</option>
        <option value="KY">Kentucky</option>
        <option value="LA">Louisiana</option>
        <option value="ME">Maine</option>
        <option value="MD">Maryland</option>
        <option value="MA">Massachusetts</option>
        <option value="MI">Michigan</option>
        <option value="MN">Minnesota</option>
        <option value="MS">Mississippi</option>
        <option value="MO">Missouri</option>
        <option value="MT">Montana</option>
        <option value="NE">Nebraska</option>
        <option value="NV">Nevada</option>
        <option value="NH">New Hampshire</option>
        <option value="NJ">New Jersey</option>
        <option value="NM">New Mexico</option>
        <option value="NY">New York</option>
        <option value="NC">North Carolina</option>
        <option value="ND">North Dakota</option>
        <option value="OH">Ohio</option>
        <option value="OK">Oklahoma</option>
        <option value="OR">Oregon</option>
        <option value="PA">Pennsylvania</option>
        <option value="RI">Rhode Island</option>
        <option value="SC">South Carolina</option>
        <option value="SD">South Dakota</option>
        <option value="TN">Tennessee</option>
        <option value="TX">Texas</option>
        <option value="UT">Utah</option>
        <option value="VT">Vermont</option>
        <option value="VA">Virginia</option>
        <option value="WA">Washington</option>
        <option value="WV">West Virginia</option>
        <option value="WI">Wisconsin</option>
        <option value="WY">Wyoming</option>
      </select>
    </form>
    <a href="/CSE135/login">Login</a>
    <%
    String action = request.getParameter("action");
    Connection conn=null;
    PreparedStatement pstmt=null;
    
    try{
        Class.forName("org.postgresql.Driver");
        conn = DriverManager.getConnection(
          "jdbc:postgresql://localhost:5432/shopping?" +
          "user=postgres&password=Ineas710");
        
        if(action != null && action.equals("insert")){
      	  conn.setAutoCommit(false);
      	  pstmt = conn.prepareStatement("INSERT INTO users (name, role, age, state) VALUES(?,?,?,?)");
      	  pstmt.setString(1,request.getParameter("name"));
      	  pstmt.setString(2, request.getParameter("role"));
      	  pstmt.setInt(3, Integer.parseInt(request.getParameter("age")));
      	  pstmt.setString(4,request.getParameter("state"));
      	  int rowCount = pstmt.executeUpdate();
      	  
      	  conn.commit();
      	  conn.setAutoCommit(true);
        }
        conn.close();
    } catch (SQLException e){
         		
    }
    finally{
      if (pstmt != null) {
        try {
          pstmt.close();
        } catch (SQLException e) { } // Ignore
      pstmt = null;
      }
      if (conn != null) {
        try {
          conn.close();
        } catch (SQLException e) { } // Ignore
        conn = null;
      }
    	
    }
    %>
  </body>
</html>