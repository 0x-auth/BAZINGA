import { Pattern, key_bazinga } from '../core/expansion-logic';
import { Blueprint } from '../core/blueprint';
import { ExpansionRules } from '../core/expansion_rule';
import { GeneratorOutput } from './PatternGenerator';

export interface DocumentConfig {
    format: 'markdown' | 'plain';
    sections: {
        overview?: boolean;
        patterns?: boolean;
        lambda?: boolean;
        execution?: boolean;
        examples?: boolean;
        implementation?: boolean;
    };
    detailLevel: 'basic' | 'detailed' | 'comprehensive';
}

export class DocumentationGenerator {
    private static readonly DEFAULT_CONFIG: DocumentConfig = {
        format: 'markdown',
        sections: {
            overview: true,
            patterns: true,
            lambda: true,
            execution: true,
            examples: true,
            implementation: true
        },
        detailLevel: 'comprehensive'
    };

    constructor(private defaultConfig: Partial<DocumentConfig> = {}) {}

    generateDocumentation(config?: Partial<DocumentConfig>): GeneratorOutput<string> {
        try {
            const fullConfig = this.getConfig(config);
            let doc = '';

            if (fullConfig.sections.overview) {
                doc += this.generateOverview(fullConfig);
            }

            if (fullConfig.sections.patterns) {
                doc += this.generatePatternDocumentation(fullConfig);
            }

            if (fullConfig.sections.lambda) {
                doc += this.generateLambdaDocumentation(fullConfig);
            }

            if (fullConfig.sections.execution) {
                doc += this.generateExecutionDocumentation(fullConfig);
            }

            if (fullConfig.sections.examples) {
                doc += this.generateExamples(fullConfig);
            }

            if (fullConfig.sections.implementation) {
                doc += this.generateImplementationGuide(fullConfig);
            }

            return { success: true, data: doc };
        } catch (error) {
            return {
                success: false,
                data: '',
                error: error instanceof Error ? error.message : 'Documentation generation failed'
            };
        }
    }

    private getConfig(config?: Partial<DocumentConfig>): DocumentConfig {
        return {
            ...DocumentationGenerator.DEFAULT_CONFIG,
            ...this.defaultConfig,
            ...config,
            sections: {
                ...DocumentationGenerator.DEFAULT_CONFIG.sections,
                ...this.defaultConfig.sections,
                ...config?.sections
            }
        };
    }

    private generateOverview(config: DocumentConfig): string {
        if (config.format === 'markdown') {
            return `# ABSYAMSY System Documentation

## Overview

ABSYAMSY (Advanced Binary System) is a sophisticated pattern-based system that uses 5-bit binary sequences to encode complex behaviors and transformations. The system combines lambda calculus with binary patterns to create a powerful and flexible framework.

### Core Components

1. Binary Patterns (5-bit sequences)
2. Lambda Calculus Rules
3. Expansion Mechanisms
4. Pattern Composition

### Key Features

- Pattern-based transformation
- Lambda calculus integration
- Compositional architecture
- Dynamic expansion

`;
        }
        return `ABSYAMSY System Documentation\n\nOverview:\n...`;
    }

    private generatePatternDocumentation(config: DocumentConfig): string {
        if (config.format === 'markdown') {
            let doc = `## Core Patterns\n\n`;

            const categories = {
                'Growth & Evolution': ['10101', '11010', '01011'],
                'Transformation': ['10111', '01100', '10010'],
                'Modulation': ['01001', '11100', '00101']
            };

            for (const [category, patterns] of Object.entries(categories)) {
                doc += `### ${category}\n\n`;
                patterns.forEach(pattern => {
                    const [lambda, meaning] = key_bazinga[pattern];
                    doc += `#### Pattern: \`${pattern}\`\n`;
                    doc += `- **Meaning**: ${meaning}\n`;
                    doc += `- **Lambda**: \`${lambda}\`\n\n`;
                });
            }

            return doc;
        }
        return `Core Patterns:\n...`;
    }

    private generateLambdaDocumentation(config: DocumentConfig): string {
        if (config.format === 'markdown') {
            return `## Lambda Calculus Rules

### Core Rules

\`\`\`typescript
λx. x + 1
λx. x * 2
λx. x - 3
\`\`\`

### Meta Rules

\`\`\`typescript
compose = λf.λg.λx. f(g(x))
iterate = λf.λn.λx. f^n(x)
invert = λf.λx. f^-1(x)
\`\`\`

`;
        }
        return `Lambda Calculus Rules:\n...`;
    }

    private generateExecutionDocumentation(config: DocumentConfig): string {
        if (config.format === 'markdown') {
            return `## Execution Flow

### Pattern Execution
1. Pattern Selection
2. Lambda Rule Application
3. Transformation Execution
4. Result Generation

### Composition Flow
1. Pattern Composition
2. Rule Synthesis
3. Execution Chain
4. Result Aggregation

`;
        }
        return `Execution Flow:\n...`;
    }

    private generateExamples(config: DocumentConfig): string {
        if (config.format === 'markdown') {
            return `## Usage Examples

### Basic Pattern Application

\`\`\`typescript
const result = generator.applyPattern('10101', 5);
const result2 = generator.applyPattern('11010', 5);
\`\`\`

### Pattern Composition

\`\`\`typescript
const composed = generator.composePatterns('10101', '11010');
const result = composed(5);
\`\`\`

`;
        }
        return `Usage Examples:\n...`;
    }

    private generateImplementationGuide(config: DocumentConfig): string {
        if (config.format === 'markdown') {
            return `## Implementation Guide

### Setup

\`\`\`typescript
import { PatternGenerator } from './generators/PatternGenerator';
import { Blueprint } from './core/blueprint';

const generator = new PatternGenerator();
\`\`\`

### Basic Usage

\`\`\`typescript
const system = generator.generateFromBlueprint(Blueprint.CORE_SEQUENCE);
const result = system.applyPattern('10101', 5);
\`\`\`

### Advanced Usage

\`\`\`typescript
const custom = generator.composePatterns('10101', '11010');
const isValid = generator.validatePatterns(['10101', '11010']);
\`\`\`

`;
        }
        return `Implementation Guide:\n...`;
    }
}

export default DocumentationGenerator;
