const traverse = require('traverse');
const jsonpath = require('jsonpath');
const tabdownParser = require('tabdown-kfatehi');

class SolutionFileExplorer {
  constructor(content) {
    this.content = content || '';
    this.solution = {};
  }

  parseNestedProject(node) {
    const regex = /\{([A-Z0-9]{8}\-[A-Z0-9]{4}\-[A-Z0-9]{4}\-[A-Z0-9]{4}\-[A-Z0-9]{12})\} = \{([A-Z0-9]{8}\-[A-Z0-9]{4}\-[A-Z0-9]{4}\-[A-Z0-9]{4}\-[A-Z0-9]{12})\}/;
    const result = regex.exec(node.value);

    if (result) {
      return {
        projectId: result[1],
        parentProjectId: result[2],
      };
    }

    return null;
  }

  parseSolutionProject(node) {
    const regex = /^Project\("\{([A-Z0-9]{8}\-[A-Z0-9]{4}\-[A-Z0-9]{4}\-[A-Z0-9]{4}\-[A-Z0-9]{12})\}"\) = "([^"]+)", "([^"]+)", "\{([A-Z0-9]{8}\-[A-Z0-9]{4}\-[A-Z0-9]{4}\-[A-Z0-9]{4}\-[A-Z0-9]{12})\}"/;
    const result = regex.exec(node.value);

    if (result) {
      return {
        id: result[4],
        name: result[2],
        relativePath: result[3],
        projectTypeId: result[1],
        children: node.children,
      };
    }

    return null;
  }

  parse(content, options) {
    this.solution = tabdownParser.parse(content, options);

    this.solution.projects = [];
    this.solution.nestedProjects = [];

    const projects = this.solution.children.reduce((acc, child) => {
      const project = this.parseSolutionProject(child);
      return project ? [...acc, project] : acc;
    }, []);

    this.solution.projects.push(...projects);

    const nestedProjectsNode = this.findNode('NestedProjects');
    if (nestedProjectsNode && nestedProjectsNode.children) {
      const nestedProjects = nestedProjectsNode.children.reduce((acc, child) => {
        const nestedProject = this.parseNestedProject(child);
        return nestedProject ? [...acc, nestedProject] : acc;
      }, []);
      this.solution.nestedProjects.push(...nestedProjects);
    }

    return this.solution;
  }

  toString() {
    return traverse(this.solution)
      .reduce(function (acc, x) {
        var hasValue = x && x.value;
        var indent = (this.level - 2) / 2;
        return hasValue && acc.push({ indent, value: x.value.trim() }), acc;
      }, [])
      .map((value) => `${'\t'.repeat(value.indent)}${value.value}`)
      .join('\r\n');
  }

  findNode(keyword) {
    const result = jsonpath.query(
      this.solution,
      `$..children[?(@.value == "${keyword}" || @.value.match(/^.*${keyword}/g))]`,
    );

    if (result && result.length) {
      return result[0];
    }

    return null;
  }

  insert(node, ...values) {
    if (node) {
      const index = this.solution.children.indexOf(node);
      this.solution.children.splice(index + 1, 0, ...values);
    }
  }

  createProjectNodes(...projects) {
    return projects.reduce((acc, project) => {
      const { projectTypeId, name, relativePath, id, children } = project;

      if (projectTypeId && id) {
        const projectNode = {
          value: `Project("{${projectTypeId}}") = "${name}", "${relativePath}", "{${id}}"`,
        };
        const projectEndNode = { value: `EndProject` };

        if (children) {
          var projectSection = children.filter((child) => !child.projectTypeId);
          if (projectSection.length) {
            projectNode.children = children;
          }
        }

        return [...acc, projectNode, projectEndNode];
      }

      return acc;
    }, []);
  }

  addNestedProjects(node, project) {
    if (node) {
      node.children = node.children || [];

      const { id, children } = project;

      if (id && children) {
        const nestedProjects = children.reduce((acc, child) => {
          if (child.children && child.children.length) {
            this.addNestedProjects(node, child);
          }
          return child.id && project.id ? [...acc, { value: `{${child.id}} = {${id}}` }] : acc;
        }, []);

        node.children.push(...nestedProjects);
      }
    }
  }

  addProjectConfigurationPlatform(node, projects, configurations) {
    if (node) {
      node.children = node.children || [];

      var results = projects.reduce(
        (acc, project) => [
          ...acc,
          ...configurations
            .map((configuration) => [
              { value: `{${project.id}}.${configuration}.ActiveCfg = ${configuration}` },
              { value: `{${project.id}}.${configuration}.Build.0 = ${configuration}` },
            ])
            .reduce((a, b) => a.concat(b)),
        ],
        [],
      );

      node.children.push(...results);
    }
  }

  addChildren(project) {
    var children = jsonpath.query(this.solution, `$..nestedProjects[?(@.parentProjectId == "${project.id}")]`);
    project.children = project.children || [];

    const results = children.reduce((acc, child) => {
      return [...acc, jsonpath.query(this.solution, `$..projects[?(@.id == "${child.projectId}")]`)[0]];
    }, []);

    project.children.push(...results);

    return project;
  }

  getProjects(projectNames) {
    this.parse(this.content, {
      linebreaks: true,
      indent: '\t',
    });
    this.solution.projects.reduce((acc, project) => [...acc, this.addChildren(project)], []);

    return projectNames.map((name) => jsonpath.query(this.solution, `$..projects[?(@.name == "${name}")]`)[0]);
  }

  addProjects(projects, settings) {
    this.parse(this.content, {
      linebreaks: true,
      indent: '\t',
    });

    projects.forEach((project) => {
      const children = jsonpath.query(project, `$..children`).reduce((a, b) => a.concat(b));
      const projectNodes = this.createProjectNodes(project, ...children);

      this.insert(this.findNode('MinimumVisualStudioVersion'), ...projectNodes);
      this.addNestedProjects(this.findNode('NestedProjects'), project);

      if (children && children.length) {
        this.addProjectConfigurationPlatform(
          this.findNode('ProjectConfigurationPlatforms'),
          children.filter((project) => project.projectTypeId === settings.codeProject),
          settings.buildConfiguration,
        );
      }
    });

    return this.solution;
  }
}

module.exports = SolutionFileExplorer;
