package com.sandboxol.blockymods.view.fragment.question;

import com.sandboxol.blockymods.R;
import com.sandboxol.blockymods.databinding.FragmentQuestionBinding;
import com.sandboxol.common.base.app.TemplateFragment;

/**
 * Created by Bob on 2017/10/23.
 */
public class QuestionFragment extends TemplateFragment<QuestionViewModel, FragmentQuestionBinding> {

    @Override
    protected int getLayoutId() {
        return R.layout.fragment_question;
    }

    @Override
    protected QuestionViewModel getViewModel() {
        return new QuestionViewModel();
    }

    @Override
    protected void bindViewModel(FragmentQuestionBinding binding, QuestionViewModel viewModel) {
        binding.setQuestionViewModel(viewModel);
    }

}
