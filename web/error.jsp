<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page isErrorPage="true"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <link rel="stylesheet" type="text/css" href="css/default.css" />          
    <title>BT: Chyba/Error</title>
  </head>
  <body>
    <div align="center">
      <fieldset style="width: 800px; text-align: left;">
        <legend>BT: Chyba/Error</legend>
        <pre>
            <%=exception.getMessage()%>
        </pre>
      </fieldset>
    </div>   
  </body>
</html>
