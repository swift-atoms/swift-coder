#if Checkpoint
    public import Parser
    public import Serializer

    extension OneOf {

        public struct Deferred<Node: Coding>
        where
            Node.Input: ~Copyable & ~Escapable,
            Node.Output: ~Copyable & Escapable,
            Node.Buffer: ~Copyable & ~Escapable
        {

            public let node: (Node.Failure) -> Node

            @inlinable
            public init(_ node: @escaping (Node.Failure) -> Node) {
                self.node = node
            }

            @inlinable
            public borrowing func callAsFunction(absent: Node.Failure) -> Node {
                node(absent)
            }
        }
    }

#endif
