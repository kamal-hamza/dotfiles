\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{resume}[2025/08/19 Custom Resume Class]

% Base class
\LoadClass[12pt,letterpaper]{article}

% Required packages
\RequirePackage[margin=0.3in]{geometry}
\RequirePackage{mathptmx}
\RequirePackage[T1]{fontenc}
\RequirePackage{enumitem}
\RequirePackage{tabularx}
\RequirePackage{array}
\RequirePackage{ifthen}
\RequirePackage{paracol}
\RequirePackage{titlesec}

% ===========================
% Global Font Size Variables
% ===========================
\newcommand{\ResumeTextSize}{\fontsize{11pt}{14pt}\selectfont}
\newcommand{\ResumeHeadingSize}{\fontsize{12pt}{15pt}\selectfont}
\newcommand{\ResumeNameSize}{\fontsize{18pt}{21pt}\selectfont}

% Remove page numbers
\pagestyle{empty}

% Set font
\renewcommand{\familydefault}{\rmdefault}

% Remove paragraph indentation
\setlength{\parindent}{0pt}
\setlength{\parskip}{6pt}

% Column layout configuration
\columnratio{0.33,0.63}
\setlength{\columnsep}{3.5em}
\setlength{\columnseprule}{0.5pt}
% \columnseprulecolor{black}

% Section formatting with horizontal line divider
\titleformat{\section}{\ResumeHeadingSize\bfseries}{}{0em}{}
\titlespacing*{\section}{0pt}{0.7em}{0.2em}
\newcommand{\sectiondivider}{\par\vspace{0.2em}\vspace{0.8em}}
\pretocmd{\section}{\sectiondivider}{}{}

% Left column section formatting (no horizontal line)
\newcommand{\leftsectionformat}[1]{%
	\vspace{0.7em}%
	{{\ResumeHeadingSize\textbf{#1}}}%
	\vspace{0.3em}\par% Reduced spacing from 0.8em to 0.3em
}

% Name command for header (spans full width, outside columns)
\newcommand{\resumename}[1]{%
	\begin{center}%
		{{\ResumeNameSize\textbf{#1}}}%
	\end{center}%
}

% Info command for contact information (spans full width, outside columns)
\newcommand{\resumeinfo}[1]{%
	\begin{center}%
		{{\ResumeTextSize{#1}}}%
		\vspace{0.4em}% Reduce space before hrule
		\hrule%
	\end{center}%
}

% Helper commands for contact info
\newcommand{\infoitem}[1]{#1}
\newcommand{\infosep}{\,|\,}

% ========================================
% RESUME ENVIRONMENT
% ========================================
\newenvironment{resume}{%
	\ResumeTextSize%
	\begin{paracol}{2}%
		}{%
	\end{paracol}%
}

% ========================================
% LEFT COLUMN ENVIRONMENTS
% ========================================

% Links environment - LEFT COLUMN
\newenvironment{linkssection}{%
	\switchcolumn[0]%
	\leftsectionformat{LINKS}%
}{%
	\vspace{1em}%
}

% Single link entry command
\newcommand{\linkentry}[1]{%
	{\ResumeTextSize \raggedright #1}\\[0.3em]% Added \raggedright for better line breaking
}

% Skills environment - LEFT COLUMN
\newenvironment{skillssection}{%
	\switchcolumn[0]%
	\leftsectionformat{SKILLS}%
}{%
	\vspace{0.3em}%
}

% Skills category command
\newcommand{\skillcategory}[2]{%
{\ResumeTextSize \textbf{#1:}}\\[0.1em]%
{\ResumeTextSize #2}\\[0.5em]%
}

% Simple skills entry
\newcommand{\skillsentry}[1]{%
	{\ResumeTextSize \raggedright #1}\\[0.3em]% Added \raggedright for better line breaking
}

% Education environment - LEFT COLUMN
\newenvironment{educations}{%
	\switchcolumn[0]%
	\leftsectionformat{EDUCATION}%
}{%
	\vspace{0.3em}%
}

% Single education entry command
\newcommand{\educationentry}[3]{%
	{\ResumeTextSize
			\textbf{#1}\\[0.1em]%
			\textit{#2}\\[0.1em]%
			#3\\[0.5em]%
		}%
}

% Relevant Courses environment - LEFT COLUMN
\newenvironment{coursessection}{%
	\switchcolumn[0]%
	\leftsectionformat{RELEVANT COURSES}%
	\vspace{-0.2em}% Reduce space between heading and bullet points
	\begin{resumelist}%
		}{%
	\end{resumelist}%
}

% Single course entry command
\newcommand{\courseentry}[1]{%
	\item #1%
}

% ========================================
% RIGHT COLUMN ENVIRONMENTS
% ========================================

% Experience environment - RIGHT COLUMN
\newenvironment{experiences}{%
	\switchcolumn[1]%
	\section{EXPERIENCE}%
}{%
	% End environment
}

% Single experience entry command
\newcommand{\experienceentry}[5]{%
	{\ResumeTextSize
			\begin{tabularx}{\linewidth}{@{}X r@{}}%
				\textbf{#1} & \textbf{#2} \\[0.1em]%
				\textit{#3} & \textit{#4} \\%
			\end{tabularx}%
			\vspace{0.3em}%
			\begin{itemize}[leftmargin=0.15in, itemsep=0.1em, parsep=0pt, topsep=0pt]%
				#5%
			\end{itemize}%
			\vspace{1em}%
		}%
}

% Projects environment - RIGHT COLUMN
\newenvironment{projects}{%
	\switchcolumn[1]%
	\section{PROJECTS}%
}{%
	% End environment
}

% Single project entry command
\newcommand{\projectentry}[3]{%
	{\ResumeTextSize
			\begin{tabularx}{\linewidth}{@{}X r@{}}%
				\textbf{#1} & \textit{#2} \\%
			\end{tabularx}%
			\vspace{0.3em}%
			\begin{itemize}[leftmargin=0.15in, itemsep=0.1em, parsep=0pt, topsep=0pt]%
				#3%
			\end{itemize}%
			\vspace{1em}%
		}%
}

% Additional sections environment - RIGHT COLUMN
\newenvironment{additionalsection}[1]{%
	\switchcolumn[1]%
	\section{#1}%
}{%
	% End environment
}

% ========================================
% UTILITY COMMANDS
% ========================================

% Custom itemize environment
\newenvironment{resumelist}{%
	\ResumeTextSize
	\begin{itemize}[leftmargin=0.15in, itemsep=0.1em, parsep=0pt, topsep=0pt]%
		}{%
	\end{itemize}%
}

% Manual column switching (if needed)
\newcommand{\toleftcolumn}{\switchcolumn[0]}
\newcommand{\torightcolumn}{\switchcolumn[1]}
