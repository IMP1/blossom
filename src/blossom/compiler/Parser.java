package blossom.compiler;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

public abstract class Parser {

    private class Logger {

        private int depth = 0;
        private PrintStream out = System.out;
        private int padding = 4;
        private StringBuilder message = new StringBuilder();

        public void push(String text) {
            message.clear();
            for (int i = 0; i < padding * depth; i ++) {
                message.append(" ");
            }
            message.append(text);
            out.println(message.toString());
            depth ++;
        }

        public void pop(String text) {
            message.clear();
            depth --;
            if (depth < 0) depth = 0;
            for (int i = 0; i < padding * depth; i ++) {
                message.append(" ");
            }
            message.append(text);
            out.println(message.toString());
        }

        public void log(String text) {
            message.clear();
            for (int i = 0; i < padding * depth; i ++) {
                message.append(" ");
            }
            message.append(text);
            out.println(message.toString());
        }

        public String last() {
            return message.toString();
        }

    }

    public boolean verbose = false;

    public static final Pattern NEWLINE      = Pattern.compile("\\r?\\n");
    public static final Pattern REST_OF_LINE = Pattern.compile(".*?\\r?\\n");

    protected String text;
    protected int position;
    protected int line;
    protected boolean finished;
    protected Loggger logger;
    
    public Parser(String text) {
        this.text = text;
        this.position = 0;
        this.line = 1;
        this.finished = false;
        this.logger = new Logger();
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
                consume(NEWLINE);
                line ++;
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
        String message = String.format("Attempted to read string '%s', got '%s'.", string, text.substring(position));
        throw new InvalidSyntaxException(message);
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
        String message = String.format("Attempted to read pattern '%s', got '%s'.", pattern.toString(), text.substring(position));
        throw new InvalidSyntaxException(message);
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

    protected String consumeOptional(String string) {
        if (beginsWith(string)) return consume(",");
        return "";
    }
    
    protected boolean eof() {
        return position == text.length();
    }

    protected void consumeRestOfLine() {
        consume(REST_OF_LINE);
    }
    
    public class InvalidSyntaxException extends RuntimeException {
        
        private static final long serialVersionUID = -2487073824658980486L;

        public InvalidSyntaxException() {
            super();
        }
        
        public InvalidSyntaxException(String message) {
            super(message 
            	+ "\n"
            	+ text.substring(Math.max(0, position - 10), Math.min(position + 10, text.length())) + "\n          ^");
        }
        
    }
    
}
