module Visitable

    def accept(visitor, *args)
        visitor.visit(self, *args)
    end
    
end


class Visitor

    def visit(subject, *args)
        method_name = "visit_#{subject.class}".intern
        send(method_name, subject, *args)
    end

end
