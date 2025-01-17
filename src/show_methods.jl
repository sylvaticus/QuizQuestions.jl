# show method for html output of question types
function _markdown_to_html(x)
    length(x) == 0 && return("")
    x = Markdown.parse(x)
    x = sprint(io -> Markdown.html(io, x))
    x = replace(x, r"^<p>"=>"", r"</p>$"=>"")
    return x
end

function Base.show(io::IO, m::MIME"text/html", x::Numericq)

    ID = randstring()

    FORM = Mustache.render(html_templates["inputq_form"];
                           ID=ID,
                           PLACEHOLDER = "Numeric answer",
                           UNITS=x.units,
                           TYPE="number",
                           HINT = length(x.label) == 0 ? x.hint : ""
                           )

    GRADING_SCRIPT =
        Mustache.render(html_templates["input_grading_script"];
                        ID = ID,
                        CORRECT_ANSWER = "(Math.abs(this.value - $(x.val)) <= $(x.tol))"
                        )

    Mustache.render(io,
                    html_templates["question_tpl"];
                    ID = ID,
                    TYPE = "text",
                    STATUS = "",
                    LABEL=_markdown_to_html(x.label),
                    HINT = length(x.label) > 0 ? x.hint : "",
                    FORM = FORM,
                    GRADING_SCRIPT = GRADING_SCRIPT
                    )

end


function Base.show(io::IO, m::MIME"text/html", x::Stringq)

    ID = randstring()

    FORM = Mustache.render(html_templates["inputq_form"];
                           ID=ID,
                           PLACEHOLDER = "Text answer",
                           TYPE="text",
                           HINT = length(x.label) == 0 ? x.hint : ""
                           )

    GRADING_SCRIPT =
        Mustache.render(html_templates["input_grading_script"];
                        ID = ID,
                        CORRECT_ANSWER = """RegExp('$(x.re.pattern)').test(this.value)"""
                        )

    Mustache.render(io, html_templates["question_tpl"];
                    ID = ID,
                    TYPE = "text",
                    STATUS = "",
                    LABEL=_markdown_to_html(x.label),
                    HINT = length(x.label) > 0 ? x.hint : "",
                    FORM = FORM,
                    GRADING_SCRIPT = GRADING_SCRIPT
                    )

end


function _make_item(i, choice)
    choice′ = sprint(io -> Markdown.html(io, Markdown.parse(choice)))
    # strip <p> tag
    choice′ = chomp(choice′)
    choice′ = replace(choice′, r"^<p>" => "")
    choice′ = replace(choice′, r"</p>$" => "")

    return (NO=i, LABEL=choice′, VALUE=i)
end



function Base.show(io::IO, m::MIME"text/html", x::Radioq)

    ID = randstring()

    choices = string.(x.choices)
    items = [_make_item(i, choice) for (i,choice) ∈ enumerate(choices)]

    GRADING_SCRIPT = Mustache.render(html_templates["radio_grading_script"];
                             ID = ID,
                             CORRECT_ANSWER = x.answer
                             )
    FORM = Mustache.render(html_templates["Radioq"];
                           ID = ID,
                           ITEMS = items,
                           INLINE = x.inline ? " inline" : ""
                           )

    Mustache.render(io, html_templates["question_tpl"],
                    ID = ID,
                    TYPE = "radio",
                    FORM = FORM,
                    GRADING_SCRIPT = GRADING_SCRIPT,
                    LABEL=_markdown_to_html(x.label),
                    HINT = x.hint # use HINT in question
                    )

end

function Base.show(io::IO, m::MIME"text/html", x::Multiq)

    ID = randstring()

    choices = string.(x.choices)
    items = [_make_item(i, choice) for (i,choice) ∈ enumerate(choices)]

    GRADING_SCRIPT = Mustache.render(html_templates["multi_grading_script"];
                                     ID = ID,
                                     CORRECT_ANSWER = x.answer,
                                     INCORRECT = "Not yet",
                                     CORRECT = "Correct"
                             )
    FORM = Mustache.render(html_templates["Multiq"];
                           ID = ID,
                           ITEMS = items,
                           INLINE = x.inline ? " inline" : ""
                           )

    Mustache.render(io, html_templates["question_tpl"],
                    ID = ID,
                    TYPE = "radio",
                    FORM = FORM,
                    GRADING_SCRIPT = GRADING_SCRIPT,
                    LABEL=_markdown_to_html(x.label),
                    HINT = x.hint # use HINT in question
                    )

end
