module Visitable

    def accept(visitor)
        visitor.visit(self)
    end
    
end


class Visitor

    def visit(subject)
        method_name = "visit_#{subject.class}".intern
        send(method_name, subject)
    end

end
