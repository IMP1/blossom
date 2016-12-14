package blossom.compiler;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

public abstract class Parser {

    public static final Pattern NEWLINE      = Pattern.compile("\\r?\\n");
    public static final Pattern REST_OF_LINE = Pattern.compile(".*?\\r?\\n");

    protected String text;
    protected int position;
    protected int line;
    protected boolean finished;
    
    public Parser(String text) {
        this.text = text;
        this.position = 0;
        this.line = 1;
        this.finished = false;
        if (text.isEmpty()) {
            this.finished = true;
        }
    }

    public boolean isFinished() {
        return finished;
    }
    
    protected void consumeWhitespace() {
        while (!eof() && Character.isWhitespace(text.charAt(position))) {
            if (beginsWith(NEWLINE)) {
                String eol = consume(NEWLINE);
                line ++;
                position += eol.length();
            } else {
                position ++;
            }
        }
    }
    
    protected boolean beginsWith(final String string) {
        return text.substring(position).startsWith(string);
    }
    
    protected boolean beginsWith(final Pattern pattern) {
        Matcher matcher = pattern.matcher(text.substring(position));
        return (matcher.find() && matcher.start() == 0);
    }
    
    protected String consume(final String string) {
        if (eof()) System.err.printf("Reached the end of the file expecting '%s'.\n", string);
        if (beginsWith(string)) {
            position += string.length();
            return string;
        }
        return "";
    }
    
    protected String consume(final Pattern pattern) {
        Matcher matcher = pattern.matcher(text.substring(position));
        if (matcher.find() && matcher.start() == 0)
        {
            int end = matcher.end();
            String result = text.substring(position, position + end);
            position += result.length();
            return result; 
        }
        return "";
    }

    protected String[] consumeAll(final Pattern pattern) {
        Matcher matcher = pattern.matcher(text.substring(position));
        if (matcher.find() && matcher.start() == 0) {
            int end = matcher.end();
            String matchedString = text.substring(position, position + end);
            String[] result = new String[0]; // TODO: put groups into a string array.
            position += matchedString.length();
            return result;
        }
        return new String[0];        
    }
    
    protected boolean eof() {
        return position == text.length();
    }

    private void consumeRestOfLine() {
        consume(REST_OF_LINE);
    }
    
    public class InvalidSyntaxException extends RuntimeException {
        
        private static final long serialVersionUID = -2487073824658980486L;

        public InvalidSyntaxException() {
            super();
        }
        
        public InvalidSyntaxException(String message) {
            super(message);
        }
        
    }
    
}
