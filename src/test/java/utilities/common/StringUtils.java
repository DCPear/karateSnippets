package utilities.common;

public class StringUtils {

    public static String bodyis(String Tittle , String Body , int UserID)
    {return "{\"title\":\""+Tittle+"\",\"body\":\""+Body+"\",\"userId\":\""+UserID+"\"}";}
}
