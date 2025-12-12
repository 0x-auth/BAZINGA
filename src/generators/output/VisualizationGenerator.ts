import { Pattern } from '../core/expansion-logic';
import { Blueprint } from '../core/blueprint';
import { GeneratorOutput } from './PatternGenerator';

export interface Node {
    id: string;
    label: string;
    type: string;
    data?: any;
}

export interface Edge {
    source: string;
    target: string;
    label?: string;
}

export interface Graph {
    nodes: Node[];
    edges: Edge[];
}

export interface VisualizationConfig {
    includeLabels?: boolean;
    includeTypes?: boolean;
    layout?: 'horizontal' | 'vertical' | 'circular';
}

export class VisualizationGenerator {
    private static readonly DEFAULT_CONFIG: VisualizationConfig = {
        includeLabels: true,
        includeTypes: true,
        layout: 'horizontal'
    };

    /**
     * Generate visualization data for pattern sequence
     */
    generateVisualization(
        patterns: Pattern[],
        config: Partial<VisualizationConfig> = {}
    ): GeneratorOutput<Graph> {
        try {
            const fullConfig = { ...VisualizationGenerator.DEFAULT_CONFIG, ...config };

            // Generate nodes
            const nodes = patterns.map(pattern => this.createNode(pattern, fullConfig));

            // Generate edges
            const edges = this.createEdges(patterns);

            return {
                success: true,
                data: { nodes, edges }
            };
        } catch (error) {
            return {
                success: false,
                data: { nodes: [], edges: [] },
                error: error instanceof Error ? error.message : 'Visualization generation failed'
            };
        }
    }

    /**
     * Generate visualization from blueprint
     */
    generateFromBlueprint(
        config: Partial<VisualizationConfig> = {}
    ): GeneratorOutput<Graph> {
        try {
            const patterns = Blueprint.getFullBlueprint().split(' ');
            return this.generateVisualization(patterns, config);
        } catch (error) {
            return {
                success: false,
                data: { nodes: [], edges: [] },
                error: error instanceof Error ? error.message : 'Blueprint visualization failed'
            };
        }
    }

    private createNode(pattern: Pattern, config: VisualizationConfig): Node {
        const meaning = Blueprint.getPatternMeaning(pattern);
        const lambda = Blueprint.getLambdaRule(pattern);

        return {
            id: pattern,
            label: config.includeLabels ? meaning : pattern,
            type: this.getPatternType(pattern),
            data: {
                pattern,
                lambda,
                meaning
            }
        };
    }

    private createEdges(patterns: Pattern[]): Edge[] {
        return patterns.slice(0, -1).map((pattern, index) => ({
            source: pattern,
            target: patterns[index + 1],
            label: this.getEdgeLabel(pattern, patterns[index + 1])
        }));
    }

    private getPatternType(pattern: Pattern): string {
        const types = {
            '10101': 'divergence',
            '11010': 'convergence',
            '01011': 'balance',
            '10111': 'distribution',
            '01100': 'cycling'
        };
        return types[pattern] || 'transform';
    }

    private getEdgeLabel(source: Pattern, target: Pattern): string {
        return `${this.getPatternType(source)} → ${this.getPatternType(target)}`;
    }

    /**
     * Generate SVG representation
     */
    generateSVG(graph: Graph, width: number = 800, height: number = 600): string {
        const svg = `<svg xmlns = "http://www.w3.org/2000/svg"
                        width = "${width}" height = "${height}" viewBox = "0 0 ${width} ${height}">
            ${this.generateSVGNodes(graph.nodes, width, height)}
            ${this.generateSVGEdges(graph.edges, width, height)}
        </svg>`;

        return svg;
    }

    private generateSVGNodes(nodes: Node[], width: number, height: number): string {
        return nodes.map((node, index) => {
            const x = (index + 1) * (width / (nodes.length + 1));
            const y = height / 2;
            return `
                <g transform = "translate(${x}, ${y})" class = "node">
                    <circle r = "20" fill = "#4299e1"/>
                    <text text-anchor = "middle" dy = ".3em">${node.id}</text>
                </g>
            `;
        }).join('');
    }

    private generateSVGEdges(edges: Edge[], width: number, height: number): string {
        return edges.map(edge => {
            const sourceIndex = edges.findIndex(e => e.source === edge.source);
            const targetIndex = edges.findIndex(e => e.target === edge.target);

            const x1 = (sourceIndex + 1) * (width / (edges.length + 2));
            const x2 = (targetIndex + 2) * (width / (edges.length + 2));
            const y = height / 2;

            return `
                <line x1 = "${x1}" y1 = "${y}" x2 = "${x2}" y2 = "${y}"
                      stroke = "#4299e1" stroke-width = "2"/>
            `;
        }).join('');
    }
}

export default VisualizationGenerator;
